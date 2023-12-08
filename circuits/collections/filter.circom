pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "./Find.circom";

/// Filter all occurences of the given item from the input array. Fitlering essentially means moving all 
/// matches to the end of the output array.
template Filter(N) {
  signal input in[N];
  signal input match; 

  signal output out[N];

  signal index_check[N];
  component find[N];
  component incr[N];

  for (var i = 0; i < N; i++) {
    find[i] = Find(N);

    // use the correct array to filter. If it's the first iteration we don't have any matches so we just use the in array as is.
    // For all the subsequent iterations we want to use the array where the previously find item has been increamented so it
    // gets ignored in the next Find execution.
    if (i == 0) {
      find[i].in <== in;
    } else {
      find[i].in <== incr[i - 1].out;
    }

    find[i].match <== match;

    // check if we found an occurence of the `match` item if there was a match, ft[i].index must be less than N.
    index_check[i] <== LessThan(8)([find[i].index, N]);
    out[i] <== match * index_check[i].out;

    // exclude found element by increamenting its value
    incr[i] = IncrementValueInTuple(N);

    // same logic like what we did above with find
    if (i == 0) {		
      incr[i].in <== in;
    } else {
      incr[i].in <== incr[i - 1].out;			
    }

    // if nothing found then find[i].index will be N so IncrementValue will simply run it's tuple and do nothin i.e. noop
    incr[i].index <== find[i].index;
  }
}
