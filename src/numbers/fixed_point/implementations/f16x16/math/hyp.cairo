use orion::numbers::fixed_point::implementations::f16x16::core::{
    HALF, ONE, TWO, f16x16, f16x16Impl, FixedTrait
};

// Calculates hyperbolic cosine of a (fixed point)
fn cosh(a: f16x16) -> f16x16 {
    let ea = a.exp();

    FixedTrait::div(ea + FixedTrait::div(FixedTrait::ONE(), ea), FixedTrait::new(TWO))
}

// Calculates hyperbolic sine of a (fixed point)
fn sinh(a: f16x16) -> f16x16 {
    let ea = a.exp();

    FixedTrait::div(ea - FixedTrait::div(FixedTrait::ONE(), ea), FixedTrait::new(TWO))
}

// Calculates hyperbolic tangent of a (fixed point)
fn tanh(a: f16x16) -> f16x16 {
    let ea = a.exp();
    let ea_i = FixedTrait::div(FixedTrait::ONE(), ea);

    FixedTrait::div(ea - ea_i, ea + ea_i)
}

// Calculates inverse hyperbolic cosine of a (fixed point)
fn acosh(a: f16x16) -> f16x16 {
    let root = (FixedTrait::mul(a, a) - FixedTrait::ONE()).sqrt();

    (a + root).ln()
}

// Calculates inverse hyperbolic sine of a (fixed point)
fn asinh(a: f16x16) -> f16x16 {
    let root = (FixedTrait::mul(a, a) + FixedTrait::ONE()).sqrt();

    (a + root).ln()
}

// Calculates inverse hyperbolic tangent of a (fixed point)
fn atanh(a: f16x16) -> f16x16 {
    let one = FixedTrait::ONE();
    let ln_arg = FixedTrait::div(one + a, one - a);

    FixedTrait::div(ln_arg.ln(), FixedTrait::new(TWO))
}

// Tests --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use orion::numbers::fixed_point::implementations::f16x16::helpers::assert_precise;

    use super::{FixedTrait, TWO, cosh, ONE, sinh, tanh, acosh, asinh, atanh, HALF};

    #[test]
    #[available_gas(10000000)]
    fn test_cosh() {
        let a = FixedTrait::new(TWO);
        assert_precise(cosh(a), 246550, 'invalid two', Option::None(())); // 3.5954653836066

        let a = FixedTrait::ONE();
        assert_precise(cosh(a), 101127, 'invalid one', Option::None(())); // 1.42428174592510

        let a = FixedTrait::ZERO();
        assert_precise(cosh(a), ONE.into(), 'invalid zero', Option::None(()));

        let a = -FixedTrait::ONE();
        assert_precise(cosh(a), 101127, 'invalid neg one', Option::None(())); // 1.42428174592510

        let a = FixedTrait::new(-TWO);
        assert_precise(cosh(a), 246568, 'invalid neg two', Option::None(())); // 3.5954653836066
    }

    #[test]
    #[available_gas(10000000)]
    fn test_sinh() {
        let a = FixedTrait::new(TWO);
        assert_precise(sinh(a), 237681, 'invalid two', Option::None(())); // 3.48973469357602

        let a = FixedTrait::ONE();
        assert_precise(sinh(a), 77018, 'invalid one', Option::None(())); // 1.13687593250230

        let a = FixedTrait::ZERO();
        assert(sinh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(-ONE);
        assert_precise(sinh(a), -77018, 'invalid neg one', Option::None(())); // -1.13687593250230

        let a = FixedTrait::new(-TWO);
        assert_precise(sinh(a), -237699, 'invalid neg two', Option::None(())); // -3.48973469357602
    }

    #[test]
    #[available_gas(10000000)]
    fn test_tanh() {
        let a = FixedTrait::new(TWO);
        assert_precise(tanh(a), 63179, 'invalid two', Option::None(())); // 0.75314654693321

        let a = FixedTrait::ONE();
        assert_precise(tanh(a), 49912, 'invalid one', Option::None(())); // 0.59499543433175

        let a = FixedTrait::ZERO();
        assert(tanh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(-ONE);
        assert_precise(tanh(a), -49912, 'invalid neg one', Option::None(())); // -0.59499543433175

        let a = FixedTrait::new(-TWO);
        assert_precise(tanh(a), -63179, 'invalid neg two', Option::None(())); // 0.75314654693321
    }

    #[test]
    #[available_gas(10000000)]
    fn test_acosh() {
        let a = FixedTrait::new(246559); // 3.5954653836066
        assert_precise(acosh(a), 131072, 'invalid two', Option::None(()));

        let a = FixedTrait::new(101127); // 1.42428174592510
        assert_precise(acosh(a), ONE.into(), 'invalid one', Option::None(()));

        let a = FixedTrait::ONE(); // 1
        assert(acosh(a).into() == 0, 'invalid zero');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_asinh() {
        let a = FixedTrait::new(237690); // 3.48973469357602
        assert_precise(asinh(a), 131072, 'invalid two', Option::None(()));

        let a = FixedTrait::new(77018); // 1.13687593250230
        assert_precise(asinh(a), ONE.into(), 'invalid one', Option::None(()));

        let a = FixedTrait::ZERO();
        assert(asinh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(-77018); // -1.13687593250230
        assert_precise(asinh(a), -ONE.into(), 'invalid neg one', Option::None(()));

        let a = FixedTrait::new(-237690); // -3.48973469357602
        assert_precise(asinh(a), -131017, 'invalid neg two', Option::None(()));
    }

    #[test]
    #[available_gas(10000000)]
    fn test_atanh() {
        let a = FixedTrait::new(58982); // 0.9
        assert_precise(atanh(a), 96483, 'invalid 0.9', Option::None(())); // 1.36892147623689

        let a = FixedTrait::new(HALF); // 0.5
        assert_precise(atanh(a), 35999, 'invalid half', Option::None(())); // 0.42914542526098

        let a = FixedTrait::ZERO();
        assert(atanh(a).into() == 0, 'invalid zero');

        let a = FixedTrait::new(-HALF); // -0.5
        assert_precise(atanh(a), -35999, 'invalid neg half', Option::None(())); // -0.42914542526098

        let a = FixedTrait::new(-58982); // -0.9
        assert_precise(atanh(a), -96483, 'invalid -0.9', Option::None(())); // -1.36892147623689
    }
}
