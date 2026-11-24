use core::fmt;

use creusot_std::prelude::{Clone, PartialEq, *};

// - enumerations section                                                   - //

/// Error returned by fallible [`crate::RingBuffer`] operations.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SpscError {
    /// The ring buffer is at full capacity and cannot accept another element.
    Full,
}

impl DeepModel for SpscError {
    // types

    type DeepModelTy = Self;

    // logic

    #[logic(open)]
    fn deep_model(self) -> Self {
        self
    }
}

impl fmt::Display for SpscError {
    // functions

    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            | Self::Full => f.write_str("ring buffer is full"),
        }
    }
}

impl core::error::Error for SpscError {}

// -------------------------------------------------------------------------- //
// - tests                                                                  - //
// -------------------------------------------------------------------------- //

#[cfg(test)]
mod tests {
    use core::fmt::Write as _;

    use super::*;

    // - structures section                                                 - //

    struct BufWriter<'a> {
        buf: &'a mut [u8],
        pos: usize,
    }

    impl fmt::Write for BufWriter<'_> {
        // functions

        fn write_str(&mut self, s: &str) -> fmt::Result {
            let bytes = s.as_bytes();
            let rem = self.buf.len().saturating_sub(self.pos);
            if bytes.len() > rem {
                return Err(fmt::Error);
            }
            self.buf[self.pos..self.pos + bytes.len()].copy_from_slice(bytes);
            self.pos += bytes.len();
            Ok(())
        }
    }

    // - functions section                                                  - //

    #[test]
    fn spsc_error_display_and_error_trait() {
        let err = SpscError::Full;
        let err_ref: &dyn core::error::Error = &err;
        assert!(err_ref.source().is_none());
        let mut raw = [0u8; 32];
        let mut writer = BufWriter { buf: &mut raw, pos: 0 };
        write!(writer, "{err}").expect("buffer holds SpscError message");
        assert_eq!(&writer.buf[..writer.pos], b"ring buffer is full");
    }
}
