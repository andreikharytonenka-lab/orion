use core::debug::PrintTrait;

use orion::numbers::fixed_point::implementations::f16x16::core::{
    HALF, ONE, TWO, f16x16, f16x16Impl, FixedTrait
};

const DEFAULT_PRECISION: i32 = 7; // 1e-4

// To use `DEFAULT_PRECISION`, final arg is: `Option::None(())`.
// To use `custom_precision` of 430_i32: `Option::Some(430_i32)`.
fn assert_precise(result: f16x16, expected: felt252, msg: felt252, custom_precision: Option<i32>) {
    let precision = match custom_precision {
        Option::Some(val) => val,
        Option::None => DEFAULT_PRECISION,
    };

    let diff = (result - FixedTrait::from_felt(expected)).abs();

    if (diff > precision) {
        result.print();
        assert(diff <= precision, msg);
    }
}

fn assert_relative(result: f16x16, expected: felt252, msg: felt252, custom_precision: Option<i32>) {
    let precision = match custom_precision {
        Option::Some(val) => val,
        Option::None => DEFAULT_PRECISION,
    };

    let diff = result - FixedTrait::from_felt(expected);
    let rel_diff = FixedTrait::div(diff, result).abs();

    if (rel_diff > precision) {
        result.print();
        assert(rel_diff <= precision, msg);
    }
}
