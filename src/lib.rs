#![no_std]

use creusot_std::prelude::*;

#[requires(v@.len() > 0)]
#[ensures((^v)@.len() == v@.len())]
#[ensures(forall<i: Int> 0 <= i && i < v@.len() ==> (^v)@[i]@ == 0)]
pub fn zero_slice(v: &mut [u8]) {
    let len = v.len();
    let mut i = 0;

    #[invariant(0 <= i@ && i@ <= len@)]
    #[invariant(v@.len() == len@)]
    #[invariant(forall<j: Int> 0 <= j && j < i@ ==> v@[j]@ == 0)]
    while i < len {
        v[i] = 0;
        i += 1;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_zero_slice() {
        let mut buf = [0xFF; 4];
        zero_slice(&mut buf);
        assert_eq!(buf, [0, 0, 0, 0]);
    }
}
