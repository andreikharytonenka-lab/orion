use core::integer;

use orion::numbers::{I32Div, I32Rem, I64Div, U32IntoI32};
use orion::numbers::fixed_point::implementations::f16x16::core::{
    HALF, ONE, MAX, MIN, f16x16, f16x16Impl, FixedTrait
};
use orion::numbers::fixed_point::implementations::f16x16::math::lut;

// PUBLIC
fn abs(a: f16x16) -> f16x16 {
    if a >= 0 {
        a
    } else {
        a * -1_i32
    }
}

fn add(a: f16x16, b: f16x16) -> f16x16 {
    a + b
}

fn ceil(a: f16x16) -> f16x16 {
    let div = Div::div(a, ONE);
    let rem = Rem::rem(a, ONE);

    if rem == 0 {
        a
    } else if a >= 0 {
        FixedTrait::new_unscaled(div + 1)
    } else {
        FixedTrait::new_unscaled(div)
    }
}

fn div(a: f16x16, b: f16x16) -> f16x16 {
    let a_i64 = integer::i32_wide_mul(a, ONE);
    let res_i64 = a_i64 / b.into();

    FixedTrait::new(res_i64.try_into().unwrap())
}

fn eq(a: @f16x16, b: @f16x16) -> bool {
    *a == *b
}

// Calculates the natural exponent of x: e^x
fn exp(a: f16x16) -> f16x16 {
    exp2(FixedTrait::mul(FixedTrait::new(94548), a)) // log2(e) * 2^16 ≈ 94548
}

// Calculates the binary exponent of x: 2^x
fn exp2(a: f16x16) -> f16x16 {
    if (a == 0) {
        return FixedTrait::ONE();
    }

    let int_part = Div::div(a.abs(), ONE);
    let frac_part = Rem::rem(a.abs(), ONE);
    let int_res = FixedTrait::new_unscaled(lut::exp2(int_part));
    let mut res_u = int_res;

    if frac_part != 0 {
        let frac = FixedTrait::new(frac_part);
        let r7 = FixedTrait::mul(FixedTrait::new(1), frac);
        let r6 = FixedTrait::mul(r7 + FixedTrait::new(10), frac);
        let r5 = FixedTrait::mul(r6 + FixedTrait::new(87), frac);
        let r4 = FixedTrait::mul(r5 + FixedTrait::new(630), frac);
        let r3 = FixedTrait::mul(r4 + FixedTrait::new(3638), frac);
        let r2 = FixedTrait::mul(r3 + FixedTrait::new(15743), frac);
        let r1 = FixedTrait::mul(r2 + FixedTrait::new(45426), frac);
        res_u = FixedTrait::mul(res_u, r1 + FixedTrait::ONE());
    }

    if a < 0 {
        FixedTrait::div(FixedTrait::ONE(), res_u)
    } else {
        res_u
    }
}

fn exp2_int(exp: i32) -> f16x16 {
    FixedTrait::new_unscaled(lut::exp2(exp))
}

fn floor(a: f16x16) -> f16x16 {
    let div = Div::div(a, ONE);
    let rem = Rem::rem(a, ONE);

    if rem == 0 {
        a
    } else if a >= 0 {
        FixedTrait::new_unscaled(div)
    } else {
        FixedTrait::new_unscaled(div - 1)
    }
}

fn ge(a: f16x16, b: f16x16) -> bool {
    a >= b
}

fn gt(a: f16x16, b: f16x16) -> bool {
    a > b
}

fn le(a: f16x16, b: f16x16) -> bool {
    a <= b
}

// Calculates the natural logarithm of x: ln(x)
// self must be greater than zero
fn ln(a: f16x16) -> f16x16 {
    FixedTrait::mul(FixedTrait::new(45426), log2(a)) // ln(2) = 0.693...
}

// Calculates the binary logarithm of x: log2(x)
// self must be greather than zero
fn log2(a: f16x16) -> f16x16 {
    assert(a > 0, 'must be positive');

    if (a == ONE) {
        return FixedTrait::ZERO();
    } else if (a < ONE) {
        // Compute true inverse binary log if 0 < x < 1
        let div = FixedTrait::div(FixedTrait::ONE(), a);
        return -log2(div);
    }

    let whole = a / ONE;
    let (msb, div) = lut::msb(whole);

    if a == div * ONE {
        FixedTrait::new_unscaled(msb)
    } else {
        let norm = FixedTrait::div(a, FixedTrait::new_unscaled(div));
        let r8 = FixedTrait::mul(FixedTrait::new(-596), norm);
        let r7 = FixedTrait::mul(r8 + FixedTrait::new(8116), norm);
        let r6 = FixedTrait::mul(r7 + FixedTrait::new(-49044), norm);
        let r5 = FixedTrait::mul(r6 + FixedTrait::new(172935), norm);
        let r4 = FixedTrait::mul(r5 + FixedTrait::new(-394096), norm);
        let r3 = FixedTrait::mul(r4 + FixedTrait::new(608566), norm);
        let r2 = FixedTrait::mul(r3 + FixedTrait::new(-655828), norm);
        let r1 = FixedTrait::mul(r2 + FixedTrait::new(534433), norm);

        r1 + FixedTrait::new(-224487) + FixedTrait::new_unscaled(msb)
    }
}

// Calculates the base 10 log of x: log10(x)
// self must be greater than zero
fn log10(a: f16x16) -> f16x16 {
    FixedTrait::mul(FixedTrait::new(19728), log2(a)) // log10(2) = 0.301...
}

fn lt(a: f16x16, b: f16x16) -> bool {
    a < b
}

fn mul(a: f16x16, b: f16x16) -> f16x16 {
    let prod_i64 = integer::i32_wide_mul(a, b);

    FixedTrait::new((prod_i64 / ONE.into()).try_into().unwrap())
}

fn ne(a: @f16x16, b: @f16x16) -> bool {
    *a != *b
}

fn neg(a: f16x16) -> f16x16 {
    -a
}

// Calclates the value of x^y and checks for overflow before returning
// self is a f16x16 point value
// b is a f16x16 point value
fn pow(a: f16x16, b: f16x16) -> f16x16 {
    let rem = Rem::rem(b, ONE);

    // use the more performant integer pow when y is an int
    if (rem == 0) {
        return pow_int(a, b / ONE);
    }

    // x^y = exp(y*ln(x)) for x > 0 will error for x < 0
    exp(FixedTrait::mul(b, ln(a)))
}

// Calclates the value of a^b and checks for overflow before returning
fn pow_int(a: f16x16, b: i32) -> f16x16 {
    let mut x = a;
    let mut n = abs(b);

    if b < 0 {
        x = FixedTrait::div(ONE, x);
    }

    if n == 0 {
        return ONE;
    }

    let mut y = ONE;
    let two: i32 = 2;

    while n > 1 {
        let div = Div::div(n, two);
        let rem = Rem::rem(n, two);

        if rem == 1 {
            y = FixedTrait::mul(x, y);
        }

        x = FixedTrait::mul(x, x);
        n = div;
    };

    FixedTrait::mul(x, y)
}

fn rem(a: f16x16, b: f16x16) -> f16x16 {
    a - FixedTrait::mul(floor(FixedTrait::div(a, b)), b)
}

fn round(a: f16x16) -> f16x16 {
    let div = Div::div(a, ONE);
    let rem = Rem::rem(a, ONE);

    if (HALF <= rem) {
        FixedTrait::new_unscaled(div + 1)
    } else if (-rem >= HALF) {
        FixedTrait::new_unscaled(div - 1)
    } else {
        FixedTrait::new_unscaled(div)
    }
}

// Calculates the square root of a f16x16 point value
// x must be positive
fn sqrt(a: f16x16) -> f16x16 {
    assert(a >= 0, 'must be positive');

    let val_u64: u64 = a.try_into().unwrap();
    let one_u64: u64 = ONE.try_into().unwrap();
    let root = integer::u64_sqrt(val_u64 * one_u64);

    FixedTrait::new(root.into())
}

fn sub(a: f16x16, b: f16x16) -> f16x16 {
    a - b
}

fn sign(a: f16x16) -> f16x16 {
    if a == 0 {
        FixedTrait::new(0)
    } else if a > 0 {
        ONE
    } else {
        -ONE
    }
}

// Tests --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use orion::numbers::{I32Div, I32Rem};
    use orion::numbers::fixed_point::implementations::f16x16::helpers::{
        assert_precise, assert_relative
    };
    use orion::numbers::fixed_point::implementations::f16x16::math::trig::{PI, HALF_PI};

    use super::{
        FixedTrait, f16x16Impl, ONE, HALF, f16x16, ceil, floor, sqrt, round, lut, pow, exp, exp2,
        exp2_int, ln, log2, log10, eq, add, sub, mul, div, rem, ne
    };

    #[test]
    fn test_into() {
        let a = FixedTrait::new_unscaled(5);
        assert(a == 5 * ONE, 'invalid result');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_acos() {
        let a = FixedTrait::ONE();
        assert(a.acos() == 0, 'invalid one');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_asin() {
        let a = FixedTrait::ONE();
        assert_precise(a.asin(), HALF_PI.into(), 'invalid one', Option::None(())); // PI / 2
    }

    #[test]
    #[available_gas(2000000)]
    fn test_atan() {
        let a = FixedTrait::new(2 * ONE);
        assert_relative(a.atan(), 72558, 'invalid two', Option::None(()));
    }

    #[test]
    fn test_ceil() {
        let a = FixedTrait::new(190054); // 2.9
        assert(ceil(a) == 3 * ONE, 'invalid pos decimal');

        let b = FixedTrait::new(-190054); // -2.9
        assert(ceil(b) == -2 * ONE, 'invalid neg decimal');
    }

    #[test]
    fn test_floor() {
        let a = FixedTrait::new(190054); // 2.9
        assert(floor(a) == 2 * ONE, 'invalid pos decimal');

        let b = FixedTrait::new(-190054); // -2.9
        assert(floor(b) == -3 * ONE, 'invalid neg decimal');
    }

    #[test]
    fn test_round() {
        let a = FixedTrait::new(190054); // 2.9
        assert(round(a) == 3 * ONE, 'invalid pos decimal');

        let b = FixedTrait::new(-190054); // -2.9
        assert(round(b) == -3 * ONE, 'invalid neg decimal');
    }

    #[test]
    #[should_panic]
    fn test_sqrt_fail() {
        let a = FixedTrait::new_unscaled(-25);
        sqrt(a);
    }

    #[test]
    fn test_sqrt() {
        let mut a = FixedTrait::new_unscaled(0);
        assert(sqrt(a) == 0, 'invalid zero root');
        a = FixedTrait::new_unscaled(25);
        assert(sqrt(a) == 5 * ONE, 'invalid pos root');
    }

    #[test]
    #[available_gas(100000)]
    fn test_msb() {
        let a = FixedTrait::new_unscaled(100);
        let (msb, div) = lut::msb(a / ONE);
        assert(msb == 6, 'invalid msb');
        assert(div == 64, 'invalid msb ceil');
    }

    #[test]
    #[available_gas(600000)]
    fn test_pow() {
        let a = FixedTrait::new_unscaled(3);
        let b = FixedTrait::new_unscaled(4);
        assert(pow(a, b) == 81 * ONE, 'invalid pos base power');
    }

    #[test]
    #[available_gas(900000)]
    fn test_pow_frac() {
        let a = FixedTrait::new_unscaled(3);
        let b = FixedTrait::new(32768); // 0.5
        assert_relative(
            pow(a, b), 113512, 'invalid pos base power', Option::None(())
        ); // 1.7320508075688772
    }

    #[test]
    #[available_gas(1000000)]
    fn test_exp() {
        let a = FixedTrait::new_unscaled(2);
        assert_relative(exp(a), 484249, 'invalid exp of 2', Option::None(())); // 7.389056098793725
    }

    #[test]
    #[available_gas(400000)]
    fn test_exp2() {
        let a = FixedTrait::new_unscaled(5);
        assert(exp2(a) == 2097152, 'invalid exp2 of 2');
    }

    #[test]
    #[available_gas(20000)]
    fn test_exp2_int() {
        assert(exp2_int(5).into() == 2097152, 'invalid exp2 of 2');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_ln() {
        let mut a = FixedTrait::new_unscaled(1);
        assert(ln(a) == 0, 'invalid ln of 1');

        a = FixedTrait::new(178145);
        assert_relative(ln(a), ONE.into(), 'invalid ln of 2.7...', Option::None(()));
    }

    #[test]
    #[available_gas(1000000)]
    fn test_log2() {
        let mut a = FixedTrait::new_unscaled(32);
        assert(log2(a) == FixedTrait::new_unscaled(5), 'invalid log2 32');

        a = FixedTrait::new_unscaled(10);
        assert_relative(log2(a), 217706, 'invalid log2 10', Option::None(())); // 3.321928094887362
    }

    #[test]
    #[available_gas(1000000)]
    fn test_log10() {
        let a = FixedTrait::new_unscaled(100);
        assert_relative(log10(a), 2 * ONE.into(), 'invalid log10', Option::None(()));
    }

    #[test]
    fn test_eq() {
        let a = FixedTrait::new_unscaled(42);
        let b = FixedTrait::new_unscaled(42);
        let c = eq(@a, @b);
        assert(c, 'invalid result');
    }

    #[test]
    fn test_ne() {
        let a = FixedTrait::new_unscaled(42);
        let b = FixedTrait::new_unscaled(42);
        let c = ne(@a, @b);
        assert(!c, 'invalid result');
    }

    #[test]
    fn test_add() {
        let a = FixedTrait::new_unscaled(1);
        let b = FixedTrait::new_unscaled(2);
        assert(add(a, b) == FixedTrait::new_unscaled(3), 'invalid result');
    }

    #[test]
    fn test_add_eq() {
        let mut a = FixedTrait::new_unscaled(1);
        let b = FixedTrait::new_unscaled(2);
        a += b;
        assert(a == FixedTrait::new_unscaled(3), 'invalid result');
    }

    #[test]
    fn test_sub() {
        let a = FixedTrait::new_unscaled(5);
        let b = FixedTrait::new_unscaled(2);
        let c = sub(a, b);
        assert(c == FixedTrait::new_unscaled(3), 'false result invalid');
    }

    #[test]
    fn test_sub_eq() {
        let mut a = FixedTrait::new_unscaled(5);
        let b = FixedTrait::new_unscaled(2);
        a -= b;
        assert(a == FixedTrait::new_unscaled(3), 'invalid result');
    }

    #[test]
    #[available_gas(100000)]
    fn test_mul_pos() {
        let a = FixedTrait::new(190054);
        let b = FixedTrait::new(190054);
        let c = mul(a, b);
        assert(c == 551155, 'invalid result');
    }

    #[test]
    fn test_mul_neg() {
        let a = FixedTrait::new_unscaled(5);
        let b = FixedTrait::new_unscaled(-2);
        let c = mul(a, b);
        assert(c == FixedTrait::new_unscaled(-10), 'invalid result');
    }

    #[test]
    fn test_div() {
        let a = FixedTrait::new_unscaled(10);
        let b = FixedTrait::new(190054); // 2.9
        let c = div(a, b);
        assert(c == 225986, 'invalid pos decimal'); // 3.4482758620689653
    }

    #[test]
    fn test_rem() {
        let a = FixedTrait::new_unscaled(10);
        let b = FixedTrait::new_unscaled(3);
        let c = rem(a, b);
        assert(c == FixedTrait::new_unscaled(1), 'invalid rem');
    }

    #[test]
    fn test_le() {
        let a = FixedTrait::new_unscaled(1);
        let b = FixedTrait::new_unscaled(0);
        let c = FixedTrait::new_unscaled(-1);

        assert(a <= a, 'a <= a');
        assert(!(a <= b), 'a <= b');
        assert(!(a <= c), 'a <= c');

        assert(b <= a, 'b <= a');
        assert(b <= b, 'b <= b');
        assert(!(b <= c), 'b <= c');

        assert(c <= a, 'c <= a');
        assert(c <= b, 'c <= b');
        assert(c <= c, 'c <= c');
    }

    #[test]
    fn test_lt() {
        let a = FixedTrait::new_unscaled(1);
        let b = FixedTrait::new_unscaled(0);
        let c = FixedTrait::new_unscaled(-1);

        assert(!(a < a), 'a < a');
        assert(!(a < b), 'a < b');
        assert(!(a < c), 'a < c');

        assert(b < a, 'b < a');
        assert(!(b < b), 'b < b');
        assert(!(b < c), 'b < c');

        assert(c < a, 'c < a');
        assert(c < b, 'c < b');
        assert(!(c < c), 'c < c');
    }

    #[test]
    fn test_ge() {
        let a = FixedTrait::new_unscaled(1);
        let b = FixedTrait::new_unscaled(0);
        let c = FixedTrait::new_unscaled(-1);

        assert(a >= a, 'a >= a');
        assert(a >= b, 'a >= b');
        assert(a >= c, 'a >= c');

        assert(!(b >= a), 'b >= a');
        assert(b >= b, 'b >= b');
        assert(b >= c, 'b >= c');

        assert(!(c >= a), 'c >= a');
        assert(!(c >= b), 'c >= b');
        assert(c >= c, 'c >= c');
    }

    #[test]
    fn test_gt() {
        let a = FixedTrait::new_unscaled(1);
        let b = FixedTrait::new_unscaled(0);
        let c = FixedTrait::new_unscaled(-1);

        assert(!(a > a), 'a > a');
        assert(a > b, 'a > b');
        assert(a > c, 'a > c');

        assert(!(b > a), 'b > a');
        assert(!(b > b), 'b > b');
        assert(b > c, 'b > c');

        assert(!(c > a), 'c > a');
        assert(!(c > b), 'c > b');
        assert(!(c > c), 'c > c');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_cos() {
        let a = FixedTrait::new(HALF_PI);
        assert(a.cos() == 0, 'invalid half pi');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_sin() {
        let a = FixedTrait::new(HALF_PI);
        assert_precise(a.sin(), ONE.into(), 'invalid half pi', Option::None(()));
    }

    #[test]
    #[available_gas(2000000)]
    fn test_tan() {
        let a = FixedTrait::new(HALF_PI / 2);
        assert(a.tan() == 65536, 'invalid quarter pi');
    }

    #[test]
    #[available_gas(2000000)]
    fn test_sign() {
        let a = FixedTrait::new(0);
        assert(a.sign() == 0, 'invalid sign (0)');

        let a = FixedTrait::new(-HALF);
        assert(a.sign() == -ONE, 'invalid sign (-HALF)');

        let a = FixedTrait::new(HALF);
        assert(a.sign() == ONE, 'invalid sign (HALF)');

        let a = FixedTrait::new(-ONE);
        assert(a.sign() == -ONE, 'invalid sign (-ONE)');

        let a = FixedTrait::new(ONE);
        assert(a.sign() == ONE, 'invalid sign (ONE)');
    }

    #[test]
    #[should_panic]
    #[available_gas(2000000)]
    fn test_sign_fail() {
        let a = FixedTrait::new(-HALF);
        assert(a.sign() != -ONE, 'invalid sign (-HALF)');
    }
}
