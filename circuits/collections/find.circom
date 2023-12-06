pragma circom 2.1.6;

/// Returns the index of the last item found in this array
template Find(N) {
  signal input in[N];
  signal input match;
  
  signal match_index[N];
  match_index[0] <== N;

  signal eq[N];

  for (var i = 0; i < N; i ++) {
    eq[i] <== IsEqual([in[i], match]);
    match_index[i + 1] <== match_index[i] + eq[i] * (i - match_index[i]);
  }

  signal output index <== match_index[N];
}
