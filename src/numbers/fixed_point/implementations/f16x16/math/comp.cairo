use orion::numbers::fixed_point::implementations::f16x16::core::{f16x16, FixedTrait, f16x16Impl};

fn max(a: f16x16, b: f16x16) -> f16x16 {
    if a >= b {
        a
    } else {
        b
    }
}

fn min(a: f16x16, b: f16x16) -> f16x16 {
    if a <= b {
        a
    } else {
        b
    }
}

fn xor(a: f16x16, b: f16x16) -> bool {
    if (a == FixedTrait::ZERO() || b == FixedTrait::ZERO()) && (a != b) {
        true
    } else {
        false
    }
}

fn or(a: f16x16, b: f16x16) -> bool {
    let zero = FixedTrait::ZERO();
    if a == zero && b == zero {
        false
    } else {
        true
    }
}

fn and(a: f16x16, b: f16x16) -> bool {
    let zero = FixedTrait::ZERO();
    if a == zero || b == zero {
        false
    } else {
        true
    }
}

fn where(a: f16x16, b: f16x16, c: f16x16) -> f16x16 {
    if a == FixedTrait::ZERO() {
        c
    } else {
        b
    }
}

// Tests --------------------------------------------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::{FixedTrait, max, min, xor, or, and, where};

    #[test]
    fn test_max() {
        let a = FixedTrait::new_unscaled(1);
        let b = FixedTrait::new_unscaled(0);
        let c = FixedTrait::new_unscaled(-1);

        assert(max(a, a) == a, 'max(a, a)');
        assert(max(a, b) == a, 'max(a, b)');
        assert(max(a, c) == a, 'max(a, c)');

        assert(max(b, a) == a, 'max(b, a)');
        assert(max(b, b) == b, 'max(b, b)');
        assert(max(b, c) == b, 'max(b, c)');

        assert(max(c, a) == a, 'max(c, a)');
        assert(max(c, b) == b, 'max(c, b)');
        assert(max(c, c) == c, 'max(c, c)');
    }

    #[test]
    fn test_min() {
        let a = FixedTrait::new_unscaled(1);
        let b = FixedTrait::new_unscaled(0);
        let c = FixedTrait::new_unscaled(-1);

        assert(min(a, a) == a, 'min(a, a)');
        assert(min(a, b) == b, 'min(a, b)');
        assert(min(a, c) == c, 'min(a, c)');

        assert(min(b, a) == b, 'min(b, a)');
        assert(min(b, b) == b, 'min(b, b)');
        assert(min(b, c) == c, 'min(b, c)');

        assert(min(c, a) == c, 'min(c, a)');
        assert(min(c, b) == c, 'min(c, b)');
        assert(min(c, c) == c, 'min(c, c)');
    }

    #[test]
    fn test_logic_ops() {
        let a = FixedTrait::new_unscaled(1);
        let z = FixedTrait::ZERO();
        let n = FixedTrait::new_unscaled(-1);

        assert(xor(a, z), 'xor(1, 0)');
        assert(!xor(a, a), 'xor(1, 1)');
        assert(or(a, z), 'or(1, 0)');
        assert(!or(z, z), 'or(0, 0)');
        assert(and(a, n), 'and(1, -1)');
        assert(!and(a, z), 'and(1, 0)');
        assert(where(a, a, n) == a, 'where(1, a, n)');
        assert(where(z, a, n) == n, 'where(0, a, n)');
    }
}
