pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "./Find.circom";

/// Filtes all zeros from the given array. It moves them to the back of the out array. Similar to Filter but more
/// more specific version where match is every other value except for 0s


// At the moment this works with max array size of 100 elements. 
template FilterZeros(N) {

}
