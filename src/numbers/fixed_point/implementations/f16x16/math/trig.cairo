use orion::numbers::{I32Div, I32Rem};
use orion::numbers::fixed_point::implementations::f16x16::math::lut;
use orion::numbers::fixed_point::implementations::f16x16::core::{
    HALF, ONE, TWO, f16x16, f16x16Impl, FixedTrait
};

// CONSTANTS
const TWO_PI: i32 = 411775;
const PI: i32 = 205887;
const HALF_PI: i32 = 102944;

// PUBLIC

// Calculates arccos(a) for -1 <= a <= 1 (fixed point)
// arccos(a) = arcsin(sqrt(1 - a^2)) - arctan identity has discontinuity at zero
fn acos(a: f16x16) -> f16x16 {
    let asin_arg = (FixedTrait::ONE() - FixedTrait::mul(a, a)).sqrt(); // will fail if a > 1
    let asin_res = asin(asin_arg);

    if a < 0 {
        FixedTrait::new(PI) - asin_res
    } else {
        asin_res
    }
}

fn acos_fast(a: f16x16) -> f16x16 {
    let asin_arg = (FixedTrait::ONE() - FixedTrait::mul(a, a)).sqrt(); // will fail if a > 1
    let asin_res = asin_fast(asin_arg);

    if a < 0 {
        FixedTrait::new(PI) - asin_res
    } else {
        asin_res
    }
}

// Calculates arcsin(a) for -1 <= a <= 1 (fixed point)
// arcsin(a) = arctan(a / sqrt(1 - a^2))
fn asin(a: f16x16) -> f16x16 {
    if (a == ONE) {
        return FixedTrait::new(HALF_PI);
    }
    if (a == -ONE) {
        return FixedTrait::new(-HALF_PI);
    }

    let div = (FixedTrait::ONE() - FixedTrait::mul(a, a)).sqrt(); // will fail if a > 1

    atan(FixedTrait::div(a, div))
}

fn asin_fast(a: f16x16) -> f16x16 {
    if (a == ONE) {
        return FixedTrait::new(HALF_PI);
    }
    if (a == -ONE) {
        return FixedTrait::new(-HALF_PI);
    }

    let div = (FixedTrait::ONE() - FixedTrait::mul(a, a)).sqrt(); // will fail if a > 1

    atan_fast(FixedTrait::div(a, div))
}

// Calculates arctan(a) (fixed point)
// See https://stackoverflow.com/a/50894477 for range adjustments
fn atan(a: f16x16) -> f16x16 {
    let mut at = a.abs();
    let mut shift = false;
    let mut invert = false;

    // Invert value when a > 1
    if (at > ONE) {
        at = FixedTrait::div(FixedTrait::ONE(), at);
        invert = true;
    }

    // Account for lack of precision in polynomial when a > 0.7
    if (at > 45875) {
        let sqrt3_3 = FixedTrait::new(37837); // sqrt(3) / 3
        at = FixedTrait::div(at - sqrt3_3, FixedTrait::ONE() + FixedTrait::mul(at, sqrt3_3));
        shift = true;
    }

    let r10 = FixedTrait::mul(FixedTrait::new(-120), at);
    let r9 = FixedTrait::mul(r10 + FixedTrait::new(-3066), at);
    let r8 = FixedTrait::mul(r9 + FixedTrait::new(12727), at);
    let r7 = FixedTrait::mul(r8 + FixedTrait::new(-17170), at);
    let r6 = FixedTrait::mul(r7 + FixedTrait::new(2865), at);
    let r5 = FixedTrait::mul(r6 + FixedTrait::new(12456), at);
    let r4 = FixedTrait::mul(r5 + FixedTrait::new(90), at);
    let r3 = FixedTrait::mul(r4 + FixedTrait::new(-21852), at);
    let r2 = FixedTrait::mul(r3, at);
    let mut res = FixedTrait::mul(r2 + FixedTrait::new(65536), at);

    // Adjust for sign change, inversion, and shift
    if (shift) {
        res = res + FixedTrait::new(34315); // pi / 6
    }

    if (invert) {
        res = res - FixedTrait::new(HALF_PI);
    }

    FixedTrait::mul(res.abs(), a.sign())
}

fn atan_fast(a: f16x16) -> f16x16 {
    let mut at = a.abs();
    let mut shift = false;
    let mut invert = false;

    // Invert value when a > 1
    if (at > ONE) {
        at = FixedTrait::div(FixedTrait::ONE(), at);
        invert = true;
    }

    // Account for lack of precision in polynomial when a > 0.7
    if (at > 45875) {
        let sqrt3_3 = FixedTrait::new(37837); // sqrt(3) / 3
        at = FixedTrait::div(at - sqrt3_3, FixedTrait::ONE() + FixedTrait::mul(at, sqrt3_3));
        shift = true;
    }

    let (start, low, high) = lut::atan(at);
    let partial_step = FixedTrait::div(FixedTrait::new(at - start).abs(), FixedTrait::new(459));
    let mut res = FixedTrait::mul(partial_step, FixedTrait::new(high - low).abs())
        + FixedTrait::new(low);

    // Adjust for sign change, inversion, and shift
    if (shift) {
        res = res + FixedTrait::new(34315); // pi / 6
    }

    if (invert) {
        res = res - FixedTrait::new(HALF_PI);
    }

    FixedTrait::mul(res.abs(), a.sign())
}

// Calculates cos(a) with a in radians (fixed point)
fn cos(a: f16x16) -> f16x16 {
    sin(FixedTrait::new(HALF_PI) - a)
}

fn cos_fast(a: f16x16) -> f16x16 {
    sin_fast(FixedTrait::new(HALF_PI) - a)
}

fn sin(a: f16x16) -> f16x16 {
    let a1 = a.abs() % TWO_PI;
    let whole_rem = Div::div(a1, PI);
    let partial_rem = Rem::rem(a1, PI);
    let a2 = FixedTrait::new(partial_rem);
    let partial_sign = whole_rem == 1;

    let loop_res = FixedTrait::mul(a2, _sin_loop(a2, 7, FixedTrait::ONE())).abs();

    if (a < 0) ^ partial_sign && loop_res != 0 {
        FixedTrait::new(-loop_res)
    } else {
        FixedTrait::new(loop_res)
    }
}

fn sin_fast(a: f16x16) -> f16x16 {
    let a1 = a.abs() % TWO_PI;
    let whole_rem = Div::div(a1, PI);
    let mut partial_rem = Rem::rem(a1, PI);
    let partial_sign = whole_rem == 1;

    if partial_rem >= HALF_PI {
        partial_rem = PI - partial_rem;
    }

    let (start, low, high) = lut::sin(partial_rem);
    let partial_step = FixedTrait::div(
        FixedTrait::new(partial_rem - start).abs(), FixedTrait::new(402)
    );
    let res = FixedTrait::mul(partial_step, (FixedTrait::new(high) - FixedTrait::new(low)))
        + FixedTrait::new(low);

    if (a < 0) ^ partial_sign && res != 0 {
        FixedTrait::new(-res)
    } else {
        FixedTrait::new(res)
    }
}

// Calculates tan(a) with a in radians (fixed point)
fn tan(a: f16x16) -> f16x16 {
    let sinx = sin(a);
    let cosx = cos(a);
    assert(cosx != 0, 'tan undefined');

    FixedTrait::div(sinx, cosx)
}

fn tan_fast(a: f16x16) -> f16x16 {
    let sinx = sin_fast(a);
    let cosx = cos_fast(a);
    assert(cosx != 0, 'tan undefined');

    FixedTrait::div(sinx, cosx)
}

// Helper function to calculate Taylor series for sin
fn _sin_loop(a: f16x16, i: i32, acc: f16x16) -> f16x16 {
    let div = (2 * i + 2) * (2 * i + 3);
    let term = FixedTrait::div(
        FixedTrait::mul(FixedTrait::mul(a, a), acc), FixedTrait::new_unscaled(div)
    );
    let new_acc = FixedTrait::ONE() - term;

    if (i == 0) {
        return new_acc;
    }

    _sin_loop(a, i - 1, new_acc)
}

// Tests --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use orion::numbers::I32Div;
    use orion::numbers::fixed_point::implementations::f16x16::helpers::{
        assert_precise, assert_relative
    };

    use super::{
        FixedTrait, acos, HALF_PI, ONE, acos_fast, PI, atan_fast, atan, asin, asin_fast, cos,
        cos_fast, sin, sin_fast, tan, tan_fast
    };

    #[test]
    #[available_gas(8000000)]
    fn test_acos() {
        let error = Option::Some(84); // 1e-5

        let a = FixedTrait::ONE();
        assert(acos(a).into() == 0, 'invalid one');

        let a = FixedTrait::new(ONE / 2);
        assert_relative(acos(a), 68629, 'invalid half', error); // 1.3687308642680

        let a = FixedTrait::ZERO();
        assert_relative(acos(a), HALF_PI.into(), 'invalid zero', Option::None(())); // PI / 2

        let a = FixedTrait::new(-ONE / 2);
        assert_relative(acos(a), 137258, 'invalid neg half', error); // 2.737461741902

        let a = FixedTrait::new(-ONE);
        assert_relative(acos(a), PI.into(), 'invalid neg one', Option::None(())); // PI
    }

    #[test]
    #[available_gas(8000000)]
    fn test_acos_fast() {
        let error = Option::Some(84); // 1e-5

        let a = FixedTrait::ONE();
        assert(acos_fast(a).into() == 0, 'invalid one');

        let a = FixedTrait::new(ONE / 2);
        assert_relative(acos_fast(a), 68629, 'invalid half', error); // 1.3687308642680

        let a = FixedTrait::ZERO();
        assert_relative(acos_fast(a), HALF_PI.into(), 'invalid zero', Option::None(())); // PI / 2

        let a = FixedTrait::new(-ONE / 2);
        assert_relative(acos_fast(a), 137258, 'invalid neg half', error); // 2.737461741902

        let a = FixedTrait::new(-ONE);
        assert_relative(acos_fast(a), PI.into(), 'invalid neg one', Option::None(())); // PI
    }

    #[test]
    #[should_panic]
    #[available_gas(8000000)]
    fn test_acos_fail() {
        let a = FixedTrait::new(-2 * ONE);
        acos(a);
    }

    #[test]
    #[available_gas(8000000)]
    fn test_atan_fast() {
        let error = Option::Some(84); // 1e-5

        let a = FixedTrait::new(2 * ONE);
        assert_relative(atan_fast(a), 72558, 'invalid two', error);

        let a = FixedTrait::ONE();
        assert_relative(atan_fast(a), 51472, 'invalid one', error);

        let a = FixedTrait::new(ONE / 2);
        assert_relative(atan_fast(a), 30386, 'invalid half', error);

        let a = FixedTrait::ZERO();
        assert(atan_fast(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(-ONE / 2);
        assert_relative(atan_fast(a), -30386, 'invalid neg half', error);

        let a = FixedTrait::new(-ONE);
        assert_relative(atan_fast(a), -51472, 'invalid neg one', error);

        let a = FixedTrait::new(-2 * ONE);
        assert_relative(atan_fast(a), -72558, 'invalid neg two', error);
    }

    #[test]
    #[available_gas(8000000)]
    fn test_atan() {
        let a = FixedTrait::new(2 * ONE);
        assert_relative(atan(a), 72558, 'invalid two', Option::None(()));

        let a = FixedTrait::ONE();
        assert_relative(atan(a), 51472, 'invalid one', Option::None(()));

        let a = FixedTrait::new(ONE / 2);
        assert_relative(atan(a), 30386, 'invalid half', Option::None(()));

        let a = FixedTrait::ZERO();
        assert(atan(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(-ONE / 2);
        assert_relative(atan(a), -30386, 'invalid neg half', Option::None(()));

        let a = FixedTrait::new(-ONE);
        assert_relative(atan(a), -51472, 'invalid neg one', Option::None(()));

        let a = FixedTrait::new(-2 * ONE);
        assert_relative(atan(a), -72558, 'invalid neg two', Option::None(()));
    }

    #[test]
    #[available_gas(8000000)]
    fn test_asin() {
        let error = Option::Some(84); // 1e-5

        let a = FixedTrait::ONE();
        assert_relative(asin(a), HALF_PI.into(), 'invalid one', Option::None(())); // PI / 2

        let a = FixedTrait::new(ONE / 2);
        assert_relative(asin(a), 34315, 'invalid half', error);

        let a = FixedTrait::ZERO();
        assert_precise(asin(a), 0, 'invalid zero', Option::None(()));

        let a = FixedTrait::new(-ONE / 2);
        assert_relative(asin(a), -34315, 'invalid neg half', error);

        let a = FixedTrait::new(-ONE);
        assert_relative(asin(a), -HALF_PI.into(), 'invalid neg one', Option::None(())); // -PI / 2
    }

    #[test]
    #[available_gas(8000000)]
    fn test_asin_fast() {
        let error = Option::Some(84); // 1e-5

        let a = FixedTrait::ONE();
        assert_relative(asin_fast(a), HALF_PI.into(), 'invalid one', Option::None(())); // PI / 2

        let a = FixedTrait::new(ONE / 2);
        assert_relative(asin_fast(a), 34315, 'invalid half', error);

        let a = FixedTrait::ZERO();
        assert_precise(asin_fast(a), 0, 'invalid zero', Option::None(()));

        let a = FixedTrait::new(-ONE / 2);
        assert_relative(asin_fast(a), -34315, 'invalid neg half', error);

        let a = FixedTrait::new(-ONE);
        assert_relative(
            asin_fast(a), -HALF_PI.into(), 'invalid neg one', Option::None(())
        ); // -PI / 2
    }

    #[test]
    #[should_panic]
    #[available_gas(8000000)]
    fn test_asin_fail() {
        let a = FixedTrait::new(2 * ONE);
        asin(a);
    }

    #[test]
    #[available_gas(8000000)]
    fn test_cos() {
        let a = FixedTrait::new(HALF_PI);
        assert(cos(a).into() == 0, 'invalid half pi');

        let a = FixedTrait::new(HALF_PI / 2);
        assert_relative(cos(a), 46341, 'invalid quarter pi', Option::None(())); // 0.55242717280199

        let a = FixedTrait::new(PI);
        assert_relative(cos(a), -1 * ONE.into(), 'invalid pi', Option::None(()));

        let a = FixedTrait::new(-HALF_PI);
        assert_precise(cos(a), 0, 'invalid neg half pi', Option::None(()));

        let a = FixedTrait::new_unscaled(17);
        assert_relative(cos(a), -18033, 'invalid 17', Option::None(())); // -0.21497123284870

        let a = FixedTrait::new_unscaled(-17);
        assert_relative(cos(a), -18033, 'invalid -17', Option::None(())); // -0.21497123284870
    }

    #[test]
    #[available_gas(8000000)]
    fn test_cos_fast() {
        let error = Option::Some(84); // 1e-5

        let a = FixedTrait::new(HALF_PI);
        assert(cos_fast(a).into() == 0, 'invalid half pi');

        let a = FixedTrait::new(HALF_PI / 2);
        assert_precise(cos_fast(a), 46341, 'invalid quarter pi', error); // 0.55242717280199

        let a = FixedTrait::new(PI);
        assert_precise(cos_fast(a), -1 * ONE.into(), 'invalid pi', error);

        let a = FixedTrait::new(-HALF_PI);
        assert_precise(cos(a), 0, 'invalid neg half pi', Option::None(()));

        let a = FixedTrait::new_unscaled(17);
        assert_precise(cos_fast(a), -18033, 'invalid 17', error); // -0.21497123284870
    }

    #[test]
    #[available_gas(8000000)]
    fn test_sin() {
        let a = FixedTrait::new(HALF_PI);
        assert_precise(sin(a), ONE.into(), 'invalid half pi', Option::None(()));

        let a = FixedTrait::new(HALF_PI / 2);
        assert_precise(sin(a), 46341, 'invalid quarter pi', Option::None(())); // 0.55242717280199

        let a = FixedTrait::new(PI);
        assert(sin(a).into() == 0, 'invalid pi');

        let a = FixedTrait::new(-HALF_PI);
        assert_precise(
            sin(a), -ONE.into(), 'invalid neg half pi', Option::None(())
        ); // 0.78124999999529

        let a = FixedTrait::new_unscaled(17);
        assert_precise(sin(a), -63006, 'invalid 17', Option::None(())); // -0.75109179053073

        let a = FixedTrait::new_unscaled(-17);
        assert_precise(sin(a), 63006, 'invalid -17', Option::None(())); // 0.75109179053073
    }

    #[test]
    #[available_gas(8000000)]
    fn test_sin_fast() {
        let error = Option::Some(84); // 1e-5

        let a = FixedTrait::new(HALF_PI);
        assert_precise(sin_fast(a), ONE.into(), 'invalid half pi', error);

        let a = FixedTrait::new(HALF_PI / 2);
        assert_precise(sin_fast(a), 46341, 'invalid quarter pi', error); // 0.55242717280199

        let a = FixedTrait::new(PI);
        assert(sin_fast(a).into() == 0, 'invalid pi');

        let a = FixedTrait::new(-HALF_PI);
        assert_precise(sin_fast(a), -ONE.into(), 'invalid neg half pi', error); // 0.78124999999529

        let a = FixedTrait::new_unscaled(17);
        assert_precise(sin_fast(a), -63006, 'invalid 17', error); // -0.75109179053073

        let a = FixedTrait::new_unscaled(-17);
        assert_precise(sin_fast(a), 63006, 'invalid -17', error); // 0.75109179053073
    }

    #[test]
    #[available_gas(8000000)]
    fn test_tan() {
        let a = FixedTrait::new(HALF_PI / 2);
        assert_precise(tan(a), ONE.into(), 'invalid quarter pi', Option::None(()));

        let a = FixedTrait::new(PI);
        assert_precise(tan(a), 0, 'invalid pi', Option::None(()));

        let a = FixedTrait::new_unscaled(17);
        assert_precise(tan(a), 228990, 'invalid 17', Option::None(())); // 3.3858731852805

        let a = FixedTrait::new_unscaled(-17);
        assert_precise(tan(a), -228952, 'invalid -17', Option::None(())); // -3.3858731852805
    }

    #[test]
    #[available_gas(8000000)]
    fn test_tan_fast() {
        let error = Option::Some(84); // 1e-5

        let a = FixedTrait::new(HALF_PI / 2);
        assert_precise(tan_fast(a), ONE.into(), 'invalid quarter pi', error);

        let a = FixedTrait::new(PI);
        assert_precise(tan_fast(a), 0, 'invalid pi', Option::None(()));

        let a = FixedTrait::new_unscaled(17);
        assert_precise(tan_fast(a), 228990, 'invalid 17', error); // 3.3858731852805

        let a = FixedTrait::new_unscaled(-17);
        assert_precise(tan_fast(a), -228952, 'invalid -17', error); // -3.3858731852805
    }
}
