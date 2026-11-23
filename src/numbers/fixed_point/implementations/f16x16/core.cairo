use orion::numbers::fixed_point::implementations::f16x16::math::{core as core_math, trig, hyp, erf};

type f16x16 = i32;

// CONSTANTS
const TWO: f16x16 = 131072; // 2 ** 17
const ONE: f16x16 = 65536; // 2 ** 16
const HALF: f16x16 = 32768; // 2 ** 15
const MAX: f16x16 = 2147483647; // 2 ** 31 - 1
const MIN: f16x16 = -2147483648; // -2 ** 31

#[generate_trait]
impl f16x16Impl of FixedTrait {
    fn ZERO() -> f16x16 {
        0
    }

    fn HALF() -> f16x16 {
        HALF
    }

    fn ONE() -> f16x16 {
        ONE
    }

    fn MAX() -> f16x16 {
        MAX
    }

    fn MIN() -> f16x16 {
        MIN
    }

    fn new(x: i32) -> f16x16 {
        x
    }

    fn new_unscaled(x: i32) -> f16x16 {
        x * ONE
    }

    fn from_felt(val: felt252) -> f16x16 {
        val.try_into().unwrap()
    }

    fn from_unscaled_felt(val: felt252) -> f16x16 {
        FixedTrait::from_felt(val * ONE.into())
    }

    fn abs(self: f16x16) -> f16x16 {
        core_math::abs(self)
    }

    fn acos(self: f16x16) -> f16x16 {
        trig::acos_fast(self)
    }

    fn acos_fast(self: f16x16) -> f16x16 {
        trig::acos_fast(self)
    }

    fn acosh(self: f16x16) -> f16x16 {
        hyp::acosh(self)
    }

    fn asin(self: f16x16) -> f16x16 {
        trig::asin_fast(self)
    }

    fn asin_fast(self: f16x16) -> f16x16 {
        trig::asin_fast(self)
    }

    fn asinh(self: f16x16) -> f16x16 {
        hyp::asinh(self)
    }

    fn atan(self: f16x16) -> f16x16 {
        trig::atan_fast(self)
    }

    fn atan_fast(self: f16x16) -> f16x16 {
        trig::atan_fast(self)
    }

    fn atanh(self: f16x16) -> f16x16 {
        hyp::atanh(self)
    }

    fn add(lhs: f16x16, rhs: f16x16) -> f16x16 {
        core_math::add(lhs, rhs)
    }

    fn ceil(self: f16x16) -> f16x16 {
        core_math::ceil(self)
    }

    fn cos(self: f16x16) -> f16x16 {
        trig::cos_fast(self)
    }

    fn cos_fast(self: f16x16) -> f16x16 {
        trig::cos_fast(self)
    }

    fn cosh(self: f16x16) -> f16x16 {
        hyp::cosh(self)
    }

    fn div(lhs: f16x16, rhs: f16x16) -> f16x16 {
        core_math::div(lhs, rhs)
    }

    fn floor(self: f16x16) -> f16x16 {
        core_math::floor(self)
    }

    // Calculates the natural exponent of x: e^x
    fn exp(self: f16x16) -> f16x16 {
        core_math::exp(self)
    }

    // Calculates the binary exponent of x: 2^x
    fn exp2(self: f16x16) -> f16x16 {
        core_math::exp2(self)
    }

    // Calculates the natural logarithm of x: ln(x)
    // self must be greater than zero
    fn ln(self: f16x16) -> f16x16 {
        core_math::ln(self)
    }

    // Calculates the binary logarithm of x: log2(x)
    // self must be greather than zero
    fn log2(self: f16x16) -> f16x16 {
        core_math::log2(self)
    }

    // Calculates the base 10 log of x: log10(x)
    // self must be greater than zero
    fn log10(self: f16x16) -> f16x16 {
        core_math::log10(self)
    }

    fn mul(lhs: f16x16, rhs: f16x16) -> f16x16 {
        core_math::mul(lhs, rhs)
    }

    // Calclates the value of x^y and checks for overflow before returning
    // self is a fixed point value
    // b is a fixed point value
    fn pow(self: f16x16, b: f16x16) -> f16x16 {
        core_math::pow(self, b)
    }

    fn rem(lhs: f16x16, rhs: f16x16) -> f16x16 {
        core_math::rem(lhs, rhs)
    }

    fn round(self: f16x16) -> f16x16 {
        core_math::round(self)
    }

    fn sin(self: f16x16) -> f16x16 {
        trig::sin_fast(self)
    }

    fn sin_fast(self: f16x16) -> f16x16 {
        trig::sin_fast(self)
    }

    fn sinh(self: f16x16) -> f16x16 {
        hyp::sinh(self)
    }

    // Calculates the square root of a fixed point value
    // x must be positive
    fn sqrt(self: f16x16) -> f16x16 {
        core_math::sqrt(self)
    }

    fn sub(lhs: f16x16, rhs: f16x16) -> f16x16 {
        core_math::sub(lhs, rhs)
    }

    fn tan(self: f16x16) -> f16x16 {
        trig::tan_fast(self)
    }

    fn tan_fast(self: f16x16) -> f16x16 {
        trig::tan_fast(self)
    }

    fn tanh(self: f16x16) -> f16x16 {
        hyp::tanh(self)
    }

    fn sign(self: f16x16) -> f16x16 {
        core_math::sign(self)
    }

    fn NaN() -> f16x16 {
        -0
    }

    fn is_nan(self: f16x16) -> bool {
        self == -0
    }

    fn INF() -> f16x16 {
        MAX
    }

    fn POS_INF() -> f16x16 {
        MAX
    }

    fn NEG_INF() -> f16x16 {
        MIN
    }

    fn is_inf(self: f16x16) -> bool {
        self == MAX || self == MIN
    }

    fn is_pos_inf(self: f16x16) -> bool {
        self == MAX
    }

    fn is_neg_inf(self: f16x16) -> bool {
        self == MIN
    }

    fn erf(self: f16x16) -> f16x16 {
        erf::erf(self)
    }
}

#[cfg(test)]
mod tests {
    use super::{FixedTrait, f16x16Impl, ONE, HALF, MAX, MIN};

    #[test]
    fn test_constants_and_constructors() {
        assert(FixedTrait::ZERO() == 0, 'invalid ZERO');
        assert(FixedTrait::HALF() == HALF, 'invalid HALF');
        assert(FixedTrait::ONE() == ONE, 'invalid ONE');
        assert(FixedTrait::MAX() == MAX, 'invalid MAX');
        assert(FixedTrait::MIN() == MIN, 'invalid MIN');

        assert(FixedTrait::new(65536) == ONE, 'invalid new');
        assert(FixedTrait::new(-65536) == -ONE, 'invalid neg new');
        assert(FixedTrait::new_unscaled(3) == 3 * ONE, 'invalid new_unscaled');
        assert(FixedTrait::new_unscaled(-3) == -3 * ONE, 'invalid neg new_unscaled');
        assert(FixedTrait::from_felt(190054) == 190054, 'invalid from_felt');
        assert(FixedTrait::from_felt(-190054) == -190054, 'invalid neg from_felt');
        assert(FixedTrait::from_unscaled_felt(2) == 2 * ONE, 'invalid from_unscaled_felt');
        assert(FixedTrait::from_unscaled_felt(-2) == -2 * ONE, 'invalid neg from_unscaled_felt');
    }

    #[test]
    fn test_special_values() {
        let nan = FixedTrait::NaN();
        assert(nan.is_nan(), 'should be nan');

        let pos_inf = FixedTrait::POS_INF();
        let neg_inf = FixedTrait::NEG_INF();
        let inf = FixedTrait::INF();

        assert(inf == pos_inf, 'INF == POS_INF');
        assert(pos_inf.is_inf(), 'pos_inf is_inf');
        assert(pos_inf.is_pos_inf(), 'pos_inf is_pos_inf');
        assert(!pos_inf.is_neg_inf(), 'pos_inf !is_neg_inf');

        assert(neg_inf.is_inf(), 'neg_inf is_inf');
        assert(neg_inf.is_neg_inf(), 'neg_inf is_neg_inf');
        assert(!neg_inf.is_pos_inf(), 'neg_inf !is_pos_inf');
    }

    #[test]
    #[available_gas(20000000)]
    fn test_trait_methods() {
        let a = FixedTrait::new_unscaled(-2);
        assert(a.abs() == FixedTrait::new_unscaled(2), 'trait abs');

        let b = FixedTrait::new(190054); // 2.9
        assert(b.ceil() == FixedTrait::new_unscaled(3), 'trait ceil');
        assert(b.floor() == FixedTrait::new_unscaled(2), 'trait floor');
        assert(b.round() == FixedTrait::new_unscaled(3), 'trait round');

        let c = FixedTrait::new_unscaled(9);
        assert(c.sqrt() == FixedTrait::new_unscaled(3), 'trait sqrt');

        let d = FixedTrait::ONE();
        assert(d.erf() == 55227, 'trait erf');
    }
}

