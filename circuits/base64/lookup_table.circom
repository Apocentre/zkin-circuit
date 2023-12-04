pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../utils/range.circom";

template GetCharForIndex() {
  signal input index;
  signal output out;

  var UPPERCASEOFFSET = 65;
  var LOWERCASEOFFSET = 71;
  var DIGITOFFSET = 4;

  signal r_1 <== Range(8)(index, 0, 25);
  signal r_2 <== Range(8)(index, 26, 51);
  signal r_3 <== Range(8)(index, 52, 61);
  signal eq_1 <== IsEqual()([index, 62]);
  signal eq_2 <== IsEqual()([index, 63]);

  // At least one of the condition above should be met. If not then it means that the index value is invalid
  signal valid_index <== GreaterThan(8)([r_1 + r_2 + r_3 + eq_1 + eq_2, 0]);
  assert(valid_index);

  // This is basically the same as having 5 if clauses. Circuits do not have the concept of if statements
  // so we have to compute all branches and return the one that matches the condition. For example, if index
  // is  in the range [0, 25] then r_1 will be equal to 1 and thus out signal will be (index + UPPERCASEOFFSET).
  // If not then we move on to check the seconds if statement which is if index is in the range [25, 51] and so on.
  // 
  // In general a condition like this if(a) { f(b) } else { g(b) } is similar to the following constaint:
  // a * f(b) = (1 - a) * g(b)
  // 
  // What wr're doing below is based on this simple interpretation of if statements in circuits with quandratic contraints.
  /**
    if (index >= 0 && index <= 25) {
      out = index + UPPERCASEOFFSET;
    } else if index >= 26 && index <= 51 {
      out = index + LOWERCASEOFFSET;
    } else if index >= 52 && index <= 61 {
      out = index - DIGITOFFSET;
    } else if index == 62 {
      out = 45;
    } else if index == 63 {
      out = 95;
    }
  **/
  signal c_5 <== eq_2 * 95;
  signal c_4 <== eq_1 * 45 + (1 - eq_1) * c_5;
  signal c_3 <== r_3 * (index - DIGITOFFSET) + (1 - r_3);
  signal c_3_i <== c_3 * c_4;
  signal c_2 <== r_2 * (index + LOWERCASEOFFSET) + (1 - r_2);
  signal c_2_i <== c_2 * c_3;
  signal c_1 <== r_1 * (index + UPPERCASEOFFSET) + (1 - r_1);

  out <== c_1 * c_2;
}

template GetIndexForChar() {
  signal input character;
  signal output out;

  var UPPERCASEOFFSET = 65;
  var LOWERCASEOFFSET = 71;
  var DIGITOFFSET = 4;

  signal r_1 <== Range(8)(character, 65, 90);
  signal r_2 <== Range(8)(character, 97, 122);
  signal r_3 <== Range(8)(character, 48, 57);
  signal eq_1 <== IsEqual()([character, 45]);
  signal eq_2 <== IsEqual()([character, 95]);

  // At least one of the condition above should be met. If not then it means that the character is invalid
  signal valid_index <== GreaterThan(8)([r_1 + r_2 + r_3 + eq_1 + eq_2, 0]);
  assert(valid_index);

  // inverse logic of what we did in `GetCharForIndex`
  signal c_5 <== eq_2 * 63;
  signal c_4 <== eq_1 * 62 + (1 - eq_1) * c_5;
  signal c_3 <== r_3 * (character + DIGITOFFSET) + (1 - r_3);
  signal c_3_i <== c_3 * c_4;
  signal c_2 <== r_2 * (character - LOWERCASEOFFSET) + (1 - r_2);
  signal c_2_i <== c_2 * c_3;
  signal c_1 <== r_1 * (character - UPPERCASEOFFSET) + (1 - r_1);

  out <== c_1 * c_2;
}

function get_padding_char() {
  // this is the equvalent of '='. Not the actual ascii code but some arbitrary value
  return 256;
}
