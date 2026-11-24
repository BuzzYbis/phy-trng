use creusot_std::prelude::*;

use crate::error::SpscError;

// - structures section                                                     - //

/// Bounded sequential FIFO ring buffer with fixed compile-time capacity `N`.
///
/// Every operation is non-blocking and bounded-step: queries and
/// single-element operations run in `O(1)`, and `new_with`, `push_slice`,
/// `pop_slice`, and `clear` complete in `O(<= N)` steps with proved
/// termination (no locks, spinning, or retries; `new` delegates to
/// `T::default()`). Concurrent wait-free SPSC transport across ISRs or
/// protection domains is out of scope here (`#![forbid(unsafe_code)]`) and
/// belongs to M6 (`ptrng-xfer` / `ptrng-sync`).
///
/// Slot index arithmetic uses branch wrapping rather than `%` so Creusot
/// discharges non-aliasing automatically (see `proofs/creusot/coverage.md`);
/// LLVM lowers the scalar wraps to branchless conditional selects in release
/// builds.
#[derive(Debug)]
pub struct RingBuffer<T, const N: usize> {
    buf:  [T; N],
    fill: T,
    head: usize,
    len:  usize,
}

impl<T, const N: usize> RingBuffer<T, N> {
    // logic

    #[logic(open(self))]
    fn slot_index(head: Int, offset: Int, cap: Int) -> Int {
        pearlite! {
            if offset < cap - head {
                head + offset
            } else {
                offset - (cap - head)
            }
        }
    }

    // private functions

    #[check(terminates)]
    #[requires(offset@ < N@)]
    #[ensures(result@ == Self::slot_index(self.head@, offset@, N@))]
    fn physical_index(&self, offset: usize) -> usize {
        let tail_room = N - self.head;
        if offset < tail_room { self.head + offset } else { offset - tail_room }
    }
}

impl<T, const N: usize> Invariant for RingBuffer<T, N> {
    // logic

    #[logic(open(self))]
    fn invariant(self) -> bool {
        pearlite! { N@ > 0 && self.head@ < N@ && self.len@ <= N@ }
    }
}

impl<T, const N: usize> View for RingBuffer<T, N> {
    // types

    type ViewTy = Seq<T>;

    // logic

    #[logic(open(self))]
    fn view(self) -> Self::ViewTy {
        pearlite! {
            Seq::create(self.len@, |i| self.buf@[Self::slot_index(self.head@, i, N@)])
        }
    }
}

impl<T: Copy + Default, const N: usize> RingBuffer<T, N> {
    // constructors

    /// Creates an empty ring buffer initialized with `T::default()`.
    #[must_use]
    #[expect(
        clippy::new_without_default,
        reason = "RingBuffer::new requires N > 0, which cannot be expressed as a precondition on core::default::Default::default"
    )]
    #[requires(N@ > 0)]
    #[ensures(result@ == Seq::empty())]
    pub fn new() -> Self {
        Self::new_with(T::default())
    }
}

impl<T: Copy, const N: usize> RingBuffer<T, N> {
    // constructors

    /// Creates an empty ring buffer whose unused and scrubbed slots hold
    /// `fill`.
    #[must_use]
    #[check(terminates)]
    #[requires(N@ > 0)]
    #[ensures(result@ == Seq::empty())]
    pub fn new_with(fill: T) -> Self {
        Self { buf: [fill; N], fill, head: 0, len: 0 }
    }

    // functions

    /// Returns the fixed capacity `N` of the ring buffer.
    #[must_use]
    #[check(terminates)]
    #[ensures(result@ == N@)]
    pub const fn capacity(&self) -> usize {
        N
    }

    /// Returns the number of stored elements currently in the ring buffer.
    #[must_use]
    #[check(terminates)]
    #[ensures(result@ == self@.len())]
    pub fn len(&self) -> usize {
        self.len
    }

    /// Returns the number of free slots remaining before the buffer is full.
    #[must_use]
    #[check(terminates)]
    #[ensures(result@ == N@ - self@.len())]
    pub fn free(&self) -> usize {
        N - self.len
    }

    /// Returns `true` if the ring buffer contains no elements.
    #[must_use]
    #[check(terminates)]
    #[ensures(result == (self@.len() == 0))]
    pub fn is_empty(&self) -> bool {
        self.len == 0
    }

    /// Returns `true` if the ring buffer is at full capacity.
    #[must_use]
    #[check(terminates)]
    #[ensures(result == (self@.len() == N@))]
    pub fn is_full(&self) -> bool {
        self.len == N
    }

    /// Returns a copy of the oldest element without removing it, or `None` if
    /// empty.
    #[must_use]
    #[check(terminates)]
    #[ensures(match result {
        None => self@.len() == 0,
        Some(v) => self@.len() > 0 && v == self@[0],
    })]
    pub fn peek(&self) -> Option<T> {
        if self.is_empty() { None } else { Some(self.buf[self.head]) }
    }

    /// Appends `value` to the tail of the ring buffer.
    ///
    /// # Errors
    ///
    /// Returns [`SpscError::Full`] without modifying the buffer if it is
    /// already at capacity.
    #[check(terminates)]
    #[ensures(match result {
        Ok(()) => (*self)@.len() < N@ && (^self)@ == (*self)@.push_back(value),
        Err(SpscError::Full) => (*self)@.len() == N@ && (^self)@ == (*self)@,
    })]
    pub fn try_push(&mut self, value: T) -> Result<(), SpscError> {
        if self.is_full() {
            return Err(SpscError::Full);
        }
        self.push_into_available(value);
        Ok(())
    }

    /// Removes and returns the oldest element, scrubbing the consumed slot with
    /// `fill`.
    #[check(terminates)]
    #[ensures(match result {
        None => (*self)@.len() == 0 && (^self)@ == (*self)@,
        Some(v) => {
            (*self)@.len() > 0
                && v == (*self)@[0]
                && (^self)@ == (*self)@.subsequence(1, (*self)@.len())
        }
    })]
    pub fn pop(&mut self) -> Option<T> {
        if self.is_empty() { None } else { Some(self.pop_non_empty()) }
    }

    /// Appends as many elements from `src` as fit, returning the count written.
    #[check(terminates)]
    #[ensures(result@ <= src@.len())]
    #[ensures(result@ <= N@ - (*self)@.len())]
    #[ensures(result@ == if src@.len() <= N@ - (*self)@.len() {
        src@.len()
    } else {
        N@ - (*self)@.len()
    })]
    #[ensures((^self)@ == (*self)@.concat(src@.subsequence(0, result@)))]
    pub fn push_slice(&mut self, src: &[T]) -> usize {
        let avail = self.free();
        let count = if src.len() <= avail { src.len() } else { avail };
        let _old_self = snapshot!(*self);
        let mut i = 0;

        #[variant(count@ - i@)]
        #[invariant(i@ <= count@)]
        #[invariant(self@ == _old_self@.concat(src@.subsequence(0, i@)))]
        while i < count {
            self.push_into_available(src[i]);
            proof_assert! {
                self@.ext_eq(_old_self@.concat(src@.subsequence(0, i@ + 1)))
            };
            i += 1;
        }
        count
    }

    /// Removes as many elements as available up to `dst.len()`, returning the
    /// count read.
    ///
    /// Consumed slots are overwritten with `fill`. Elements in `dst[count..]`
    /// are untouched.
    #[check(terminates)]
    #[ensures(result@ <= dst@.len())]
    #[ensures(result@ <= (*self)@.len())]
    #[ensures(result@ == if dst@.len() <= (*self)@.len() {
        dst@.len()
    } else {
        (*self)@.len()
    })]
    #[ensures((^dst)@.len() == (*dst)@.len())]
    #[ensures(forall<i: Int> 0 <= i && i < result@ ==> (^dst)@[i] == (*self)@[i])]
    #[ensures(forall<i: Int> result@ <= i && i < dst@.len() ==> (^dst)@[i] == (*dst)@[i])]
    #[ensures((^self)@ == (*self)@.subsequence(result@, (*self)@.len()))]
    pub fn pop_slice(&mut self, dst: &mut [T]) -> usize {
        let len = self.len();
        let count = if dst.len() <= len { dst.len() } else { len };
        let _old_self = snapshot!(*self);
        let _old_dst = snapshot!(dst@);
        let mut i = 0;

        #[variant(count@ - i@)]
        #[invariant(i@ <= count@)]
        #[invariant(dst@.len() == _old_dst.len())]
        #[invariant(self@ == _old_self@.subsequence(i@, _old_self@.len()))]
        #[invariant(forall<j: Int> 0 <= j && j < i@ ==> dst@[j] == _old_self@[j])]
        #[invariant(forall<j: Int> i@ <= j && j < dst@.len() ==> dst@[j] == (*_old_dst)[j])]
        while i < count {
            dst[i] = self.pop_non_empty();
            proof_assert! {
                self@.ext_eq(_old_self@.subsequence(i@ + 1, _old_self@.len()))
            };
            i += 1;
        }
        count
    }

    /// Resets the buffer to empty and overwrites every backing slot with
    /// `fill`.
    #[check(terminates)]
    #[ensures((^self)@ == Seq::empty())]
    pub fn clear(&mut self) {
        let mut i = 0;

        #[variant(N@ - i@)]
        #[invariant(i@ <= N@)]
        while i < N {
            self.buf[i] = self.fill;
            i += 1;
        }
        self.head = 0;
        self.len = 0;
    }

    // private functions

    #[check(terminates)]
    #[requires((*self)@.len() < N@)]
    #[ensures((^self)@ == (*self)@.push_back(value))]
    fn push_into_available(&mut self, value: T) {
        let _old_self = snapshot!(*self);
        let tail = self.physical_index(self.len);
        self.buf[tail] = value;
        self.len += 1;
        proof_assert! { self@.ext_eq(_old_self@.push_back(value)) };
    }

    #[check(terminates)]
    #[requires((*self)@.len() > 0)]
    #[ensures(result == (*self)@[0])]
    #[ensures((^self)@ == (*self)@.subsequence(1, (*self)@.len()))]
    fn pop_non_empty(&mut self) -> T {
        let _old_self = snapshot!(*self);
        let value = self.buf[self.head];
        self.buf[self.head] = self.fill;
        self.head = if self.head + 1 < N { self.head + 1 } else { 0 };
        self.len -= 1;
        proof_assert! {
            self@.ext_eq(_old_self@.subsequence(1, _old_self@.len()))
        };
        value
    }
}

// -------------------------------------------------------------------------- //
// - tests                                                                  - //
// -------------------------------------------------------------------------- //

#[cfg(test)]
mod tests {
    use super::*;

    // - structures section                                                 - //

    #[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
    struct Sample(u16);

    struct RefQueue<const N: usize> {
        data: [u16; N],
        len:  usize,
    }

    impl<const N: usize> RefQueue<N> {
        // constructors

        const fn new() -> Self {
            Self { data: [0; N], len: 0 }
        }

        // functions

        const fn peek(&self) -> Option<u16> {
            if self.len == 0 { None } else { Some(self.data[0]) }
        }

        fn try_push(&mut self, value: u16) -> Result<(), SpscError> {
            if self.len == N {
                return Err(SpscError::Full);
            }
            self.data[self.len] = value;
            self.len += 1;
            Ok(())
        }

        fn pop(&mut self) -> Option<u16> {
            if self.len == 0 {
                return None;
            }
            let out = self.data[0];
            self.data.copy_within(1..self.len, 0);
            self.len -= 1;
            Some(out)
        }

        fn push_slice(&mut self, src: &[u16]) -> usize {
            let mut written = 0;
            while written < src.len() && self.len < N {
                self.data[self.len] = src[written];
                self.len += 1;
                written += 1;
            }
            written
        }

        fn pop_slice(&mut self, dst: &mut [u16]) -> usize {
            let count = dst.len().min(self.len);
            dst[..count].copy_from_slice(&self.data[..count]);
            self.data.copy_within(count..self.len, 0);
            self.len -= count;
            count
        }

        fn clear(&mut self) {
            self.data.fill(0);
            self.len = 0;
        }
    }

    // - functions section                                                  - //

    fn next_u32(state: &mut u32) -> u32 {
        *state ^= *state << 13;
        *state ^= *state >> 17;
        *state ^= *state << 5;
        *state
    }

    fn assert_ring_matches<const N: usize>(
        ring: &RingBuffer<u16, N>,
        model: &RefQueue<N>,
    ) {
        assert_eq!(ring.capacity(), N);
        assert_eq!(ring.len(), model.len);
        assert_eq!(ring.free(), N - model.len);
        assert_eq!(ring.is_empty(), model.len == 0);
        assert_eq!(ring.is_full(), model.len == N);
        assert_eq!(ring.peek(), model.peek());
    }

    fn run_reference_trace<const N: usize>(mut seed: u32, steps: usize) {
        let mut ring: RingBuffer<u16, N> = RingBuffer::new();
        let mut model = RefQueue::new();

        for _ in 0..steps {
            let [b0, b1, b2, _] = next_u32(&mut seed).to_le_bytes();
            let val = u16::from_le_bytes([b1, b2]);
            let chunk_len = usize::from(b2 % 5);

            match b0 & 0x07 {
                | 0 | 1 => assert_eq!(ring.try_push(val), model.try_push(val)),
                | 2 | 3 => assert_eq!(ring.pop(), model.pop()),
                | 4 => {
                    let src = [val, val ^ 0x1111, val ^ 0x2222, val ^ 0x3333];
                    assert_eq!(
                        ring.push_slice(&src[..chunk_len]),
                        model.push_slice(&src[..chunk_len])
                    );
                },
                | 5 => {
                    let mut dst_ring = [0xFFFF; 4];
                    let mut dst_ref = [0xFFFF; 4];
                    let n_ring = ring.pop_slice(&mut dst_ring[..chunk_len]);
                    let n_ref = model.pop_slice(&mut dst_ref[..chunk_len]);
                    assert_eq!(n_ring, n_ref);
                    assert_eq!(dst_ring, dst_ref);
                },
                | 6 => assert_eq!(ring.peek(), model.peek()),
                | _ if b1 < 32 => {
                    ring.clear();
                    model.clear();
                },
                | _ => assert_eq!(ring.try_push(val), model.try_push(val)),
            }

            assert_ring_matches(&ring, &model);
        }
    }

    #[test]
    fn empty_and_capacity_queries() {
        let ring: RingBuffer<u8, 4> = RingBuffer::new();
        assert_eq!(ring.capacity(), 4);
        assert_eq!(ring.len(), 0);
        assert_eq!(ring.free(), 4);
        assert!(ring.is_empty());
        assert!(!ring.is_full());
        assert_eq!(ring.peek(), None);
    }

    #[test]
    fn single_element_capacity_one() {
        let mut ring: RingBuffer<u8, 1> = RingBuffer::new();
        assert_eq!(ring.try_push(42), Ok(()));
        assert!(ring.is_full());
        assert_eq!(ring.free(), 0);
        assert_eq!(ring.try_push(99), Err(SpscError::Full));
        assert_eq!(ring.peek(), Some(42));
        assert_eq!(ring.pop(), Some(42));
        assert!(ring.is_empty());
        assert_eq!(ring.pop(), None);
        assert_eq!(ring.try_push(7), Ok(()));
        assert_eq!(ring.pop(), Some(7));
    }

    #[test]
    fn fifo_and_wrap_around() {
        let mut ring: RingBuffer<u8, 4> = RingBuffer::new();
        assert_eq!(ring.try_push(1), Ok(()));
        assert_eq!(ring.try_push(2), Ok(()));
        assert_eq!(ring.try_push(3), Ok(()));
        assert_eq!(ring.pop(), Some(1));
        assert_eq!(ring.pop(), Some(2));
        assert_eq!(ring.try_push(4), Ok(()));
        assert_eq!(ring.try_push(5), Ok(()));
        assert_eq!(ring.try_push(6), Ok(()));
        assert_eq!(ring.try_push(7), Err(SpscError::Full));
        assert_eq!(ring.peek(), Some(3));
        assert_eq!(
            [ring.pop(), ring.pop(), ring.pop(), ring.pop()],
            [Some(3), Some(4), Some(5), Some(6)]
        );
    }

    #[test]
    fn push_slice_partial_and_full() {
        let mut ring: RingBuffer<u8, 4> = RingBuffer::new();
        assert_eq!(ring.push_slice(&[]), 0);
        assert_eq!(ring.push_slice(&[10, 20]), 2);
        assert_eq!(ring.push_slice(&[30, 40, 50, 60]), 2);
        assert!(ring.is_full());
        assert_eq!(ring.push_slice(&[70]), 0);
        let mut out = [0u8; 4];
        assert_eq!(ring.pop_slice(&mut out), 4);
        assert_eq!(out, [10, 20, 30, 40]);
    }

    #[test]
    fn pop_slice_partial_preserves_tail() {
        let mut ring: RingBuffer<u8, 4> = RingBuffer::new();
        assert_eq!(ring.push_slice(&[1, 2, 3]), 3);
        let mut dst = [0xAAu8; 5];
        assert_eq!(ring.pop_slice(&mut dst), 3);
        assert_eq!(dst, [1, 2, 3, 0xAA, 0xAA]);
        assert!(ring.is_empty());
        assert_eq!(ring.pop_slice(&mut dst), 0);
        assert_eq!(dst, [1, 2, 3, 0xAA, 0xAA]);
    }

    #[test]
    fn pop_scrubs_consumed_slot() {
        let mut ring: RingBuffer<u8, 3> = RingBuffer::new_with(0x55);
        assert_eq!(ring.try_push(0x11), Ok(()));
        assert_eq!(ring.try_push(0x22), Ok(()));
        assert_eq!(ring.pop(), Some(0x11));
        assert_eq!(ring.buf[0], 0x55);
        assert_eq!(ring.pop(), Some(0x22));
        assert_eq!(ring.buf[1], 0x55);
    }

    #[test]
    fn clear_resets_and_reuses() {
        let mut ring: RingBuffer<u8, 4> = RingBuffer::new_with(0xEE);
        assert_eq!(ring.push_slice(&[1, 2, 3, 4]), 4);
        assert_eq!(ring.pop(), Some(1));
        ring.clear();
        assert!(ring.is_empty());
        assert_eq!(ring.free(), 4);
        assert_eq!(ring.buf, [0xEE; 4]);
        assert_eq!(ring.push_slice(&[9, 8]), 2);
        assert_eq!(ring.pop(), Some(9));
        assert_eq!(ring.pop(), Some(8));
    }

    #[test]
    fn generic_non_byte_type() {
        let mut ring: RingBuffer<Sample, 3> = RingBuffer::new();
        assert_eq!(ring.push_slice(&[Sample(10), Sample(20)]), 2);
        assert_eq!(ring.peek(), Some(Sample(10)));
        assert_eq!(ring.pop(), Some(Sample(10)));
        assert_eq!(ring.pop(), Some(Sample(20)));
        assert_eq!(ring.pop(), None);
    }

    #[test]
    fn reference_queue_equivalence() {
        run_reference_trace::<1>(0x1A2B_3C4D, 128);
        run_reference_trace::<3>(0x2B3C_4D5E, 128);
        run_reference_trace::<4>(0x3C4D_5E6F, 128);
        run_reference_trace::<8>(0x4D5E_6F70, 128);
    }
}
