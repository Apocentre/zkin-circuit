pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "../utils/constants.circom";

/// A claim when decoded might include some characters either at the start or end (or both).
/// The set includes the following characters: [:, ", ','] and they can be located at the following positions
/// 1. two at the front i.e. indexes 0, 1 i.e. :"
/// 2. two at the end i.e. indexes len - 1, len - 2. For example ," or ",
/// 3. one at the beginning 0 and one at the end len - 1. For example " and " or : and , at the end
/// 4. only one comma at the end
/// 5. only one colon at the start
///
/// This template will remove those character from the given claim but it will make sure that it removes
/// the characters only if they are located at the aforementioned positions.
template ClaimSanitizer(max_claim_json_bytes) {
  signal input claim[max_claim_json_bytes];
  signal output out[max_claim_json_bytes];

  signal colon_at_0_index <== IsEqual()([claim[0], colon_ascii()]);
  signal quote_at_0_index <== IsEqual()([claim[0], quote_ascii()]);
  signal quote_at_1_index <== IsEqual()([claim[1], quote_ascii()]);
  signal comma_at_last_index <== IsEqual()([claim[max_claim_json_bytes - 1], comma_ascii()]);
  signal quote_at_last_index <== IsEqual()([claim[max_claim_json_bytes - 1], quote_ascii()]);
  signal comma_before_last_index <== IsEqual()([claim[max_claim_json_bytes - 2], comma_ascii()]);
  signal quote_before_last_index <== IsEqual()([claim[max_claim_json_bytes - 2], quote_ascii()]);

  signal indexes_to_remove[2];

  signal remote_first_index <== colon_at_0_index + quote_at_0_index;
  indexes_to_remove[0] <== (================) + ;
  
  // either the secods index or the last index
  indexes_to_remove[1] <== (colon_at_last_index + quote_at_last_index) * len + quote_at_1_index;
}
