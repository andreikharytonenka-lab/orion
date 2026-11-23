use orion::numbers::fixed_point::implementations::f16x16::math::erf::erf;
use orion::numbers::fixed_point::implementations::f16x16::core::{ONE, f16x16, FixedTrait};

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

    let f1_erf: f16x16 = erf(f1);
    let f2_erf: f16x16 = erf(f2);
    let f3_erf: f16x16 = erf(f3);
    let f4_erf: f16x16 = erf(f4);
    let f5_erf: f16x16 = erf(f5);
    let f6_erf: f16x16 = erf(f6);

    assert(f1_erf == 55227, 'f1_erf it works!');
    assert(f2_erf == 10285, 'f2_erf it works!');
    assert(f3_erf == 35251, 'f3_erf it works!');
    assert(f4_erf == 65229, 'f4_erf it works!');
    assert(f5_erf == 65536, 'f5_erf it works!');
    assert(f6_erf == 65536, 'f6_erf it works!');
}
