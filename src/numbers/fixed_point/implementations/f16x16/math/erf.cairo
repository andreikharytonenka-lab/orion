use orion::numbers::fixed_point::implementations::f16x16::core::{
    ONE, f16x16, FixedTrait, f16x16Impl
};
use orion::numbers::fixed_point::implementations::f16x16::math::lut::erf_lut;

const ERF_COMPUTATIONAL_ACCURACY: i32 = 100;
const ROUND_CHECK_NUMBER: i32 = 10;
// Values > MAX_ERF_NUMBER return 1
const MAX_ERF_NUMBER: i32 = 229376;
// Values <= ERF_TRUNCATION_NUMBER -> two decimal places, and values > ERF_TRUNCATION_NUMBER -> one decimal place
const ERF_TRUNCATION_NUMBER: i32 = 131072;

fn erf(x: f16x16) -> f16x16 {
    // Lookup
    // 1. if x.abs() < 3.5 { lookup table }
    // 2. else { return 1 }
    let mut erf_value: i32 = 0;

    if x.abs() < MAX_ERF_NUMBER {
        erf_value = erf_lut(x.abs());
    } else {
        erf_value = ONE;
    }

    FixedTrait::mul(erf_value, x.sign())
}

#[cfg(test)]
mod tests {
    use super::{erf, f16x16};

    #[test]
    #[available_gas(1000000000)]
    fn test_erf() {
        // 1.0
        let f1: f16x16 = 65536;
        // 0.134
        let f2: f16x16 = 8832;
        // 0.520
        let f3: f16x16 = 34078;
        // 2.0
        let f4: f16x16 = 131072;
        // 3.5
        let f5: f16x16 = 229376;
        // 5.164
        let f6: f16x16 = 338428;

        assert(erf(f1) == 55227, 'f1_erf');
        assert(erf(f2) == 10285, 'f2_erf');
        assert(erf(f3) == 35251, 'f3_erf');
        assert(erf(f4) == 65229, 'f4_erf');
        assert(erf(f5) == 65536, 'f5_erf');
        assert(erf(f6) == 65536, 'f6_erf');
        assert(erf(-f1) == -55227, '-f1_erf');
        assert(erf(0) == 0, '0_erf');
    }
}
