// 基因组学分析流水线 - DNA序列分析和模式匹配

enum Nucleotide {
  A;
  T;
  G;
  C;
}

enum MatchResult {
  NoMatch;
  Match(Int, Int);
}

struct Sequence {
  data: Array[Nucleotide];
  length: Int;
}

struct Pattern {
  seq: Sequence;
  min_score: Int;
}

struct Alignment {
  score: Int;
  position: Int;
  length: Int;
}

enum AlignmentQuality {
  Poor;
  Fair;
  Good;
  Excellent;
}

fn nucleotide_to_int(n: Nucleotide) -> Int {
  match n {
    A => 0;
    T => 1;
    G => 2;
    C => 3;
  }
}

fn int_to_nucleotide(i: Int) -> Nucleotide {
  if i == 0 {
    A
  } else if i == 1 {
    T
  } else if i == 2 {
    G
  } else {
    C
  }
}

fn make_sequence(length: Int) -> Sequence {
  let data = Array::make(length, A);
  Sequence::{ data: data, length: length }
}

fn copy_sequence(src: Sequence, dst: Sequence, len: Int) -> Unit {
  let copy_len = if len > src.length { src.length } else { len };
  let copy_len2 = if copy_len > dst.length { dst.length } else { copy_len };
  
  let mut i = 0;
  while i < copy_len2 {
    dst.data[i] = src.data[i];
    i = i + 1;
  }
}

fn complement(n: Nucleotide) -> Nucleotide {
  match n {
    A => T;
    T => A;
    G => C;
    C => G;
  }
}

fn reverse_complement(seq: Sequence, output: Sequence) -> Unit {
  let mut i = 0;
  while i < seq.length && i < output.length {
    output.data[output.length - 1 - i] = complement(seq.data[i]);
    i = i + 1;
  }
}

fn match_nucleotides(n1: Nucleotide, n2: Nucleotide) -> Int {
  if nucleotide_to_int(n1) == nucleotide_to_int(n2) {
    1
  } else {
    0 - 1
  }
}

fn align_sequences(seq1: Sequence, seq2: Sequence, start: Int) -> Int {
  let mut score = 0;
  let mut i = 0;
  
  while i < seq2.length && (start + i) < seq1.length {
    score = score + match_nucleotides(seq1.data[start + i], seq2.data[i]);
    i = i + 1;
  }
  
  score
}

fn find_pattern(seq: Sequence, pattern: Sequence) -> MatchResult {
  let mut best_score = 0 - 999999;
  let mut best_pos = 0 - 1;
  
  let mut i = 0;
  while i <= seq.length - pattern.length {
    let score = align_sequences(seq, pattern, i);
    if score > best_score {
      best_score = score;
      best_pos = i;
    };
    i = i + 1;
  }
  
  if best_pos >= 0 {
    Match(best_pos, best_score)
  } else {
    NoMatch
  }
}

fn count_gc_content(seq: Sequence) -> Int {
  let mut gc_count = 0;
  let mut i = 0;
  
  while i < seq.length {
    match seq.data[i] {
      G => { gc_count = gc_count + 1; };
      C => { gc_count = gc_count + 1; };
      _ => { () };
    };
    i = i + 1;
  }
  
  gc_count
}

fn hamming_distance(seq1: Sequence, seq2: Sequence) -> Int {
  let len = if seq1.length < seq2.length { seq1.length } else { seq2.length };
  let mut distance = 0;
  let mut i = 0;
  
  while i < len {
    if nucleotide_to_int(seq1.data[i]) != nucleotide_to_int(seq2.data[i]) {
      distance = distance + 1;
    };
    i = i + 1;
  }
  
  distance
}

fn find_motif(seq: Sequence, motif: Sequence) -> Int {
  let mut count = 0;
  let mut i = 0;
  
  while i <= seq.length - motif.length {
    let mut match_found = true;
    let mut j = 0;
    
    while j < motif.length {
      if nucleotide_to_int(seq.data[i + j]) != nucleotide_to_int(motif.data[j]) {
        match_found = false;
      };
      j = j + 1;
    }
    
    if match_found {
      count = count + 1;
    };
    i = i + 1;
  }
  
  count
}

fn transcribe(seq: Sequence, output: Sequence) -> Unit {
  let mut i = 0;
  while i < seq.length && i < output.length {
    match seq.data[i] {
      T => { output.data[i] = int_to_nucleotide(1); };
      _ => { output.data[i] = seq.data[i]; };
    };
    i = i + 1;
  }
}

fn create_consensus(seqs: Array[Sequence], num_seqs: Int, length: Int) -> Sequence {
  let consensus = make_sequence(length);
  
  let mut pos = 0;
  while pos < length {
    let counts = [0, 0, 0, 0];
    
    let mut i = 0;
    while i < num_seqs {
      if pos < seqs[i].length {
        let nuc_idx = nucleotide_to_int(seqs[i].data[pos]);
        counts[nuc_idx] = counts[nuc_idx] + 1;
      };
      i = i + 1;
    }
    
    let mut max_count = counts[0];
    let mut max_idx = 0;
    let mut j = 1;
    while j < 4 {
      if counts[j] > max_count {
        max_count = counts[j];
        max_idx = j;
      };
      j = j + 1;
    }
    
    consensus.data[pos] = int_to_nucleotide(max_idx);
    pos = pos + 1;
  }
  
  consensus
}

fn compute_alignment_quality(score: Int, max_score: Int) -> AlignmentQuality {
  let percentage = (score * 100) / max_score;
  
  if percentage >= 90 {
    Excellent
  } else if percentage >= 70 {
    Good
  } else if percentage >= 50 {
    Fair
  } else {
    Poor
  }
}

fn quality_to_int(q: AlignmentQuality) -> Int {
  match q {
    Poor => 0;
    Fair => 1;
    Good => 2;
    Excellent => 3;
  }
}

fn test_complement() -> Unit {
  let seq = make_sequence(5);
  seq.data[0] = A;
  seq.data[1] = T;
  seq.data[2] = G;
  seq.data[3] = C;
  seq.data[4] = A;
  
  let rc = make_sequence(5);
  reverse_complement(seq, rc);
  
  let mut i = 0;
  while i < 5 {
    println(nucleotide_to_int(rc.data[i]));
    i = i + 1;
  }
}

fn test_gc_content() -> Unit {
  let seq = make_sequence(10);
  seq.data[0] = A;
  seq.data[1] = T;
  seq.data[2] = G;
  seq.data[3] = C;
  seq.data[4] = G;
  seq.data[5] = G;
  seq.data[6] = C;
  seq.data[7] = A;
  seq.data[8] = T;
  seq.data[9] = G;
  
  let gc = count_gc_content(seq);
  println(gc);
}

fn test_pattern_matching() -> Unit {
  let seq = make_sequence(12);
  seq.data[0] = A;
  seq.data[1] = T;
  seq.data[2] = G;
  seq.data[3] = C;
  seq.data[4] = A;
  seq.data[5] = T;
  seq.data[6] = G;
  seq.data[7] = C;
  seq.data[8] = A;
  seq.data[9] = A;
  seq.data[10] = T;
  seq.data[11] = G;
  
  let pattern = make_sequence(3);
  pattern.data[0] = A;
  pattern.data[1] = T;
  pattern.data[2] = G;
  
  let result = find_pattern(seq, pattern);
  
  match result {
    NoMatch => { println(0 - 1); };
    Match(pos, score) => {
      println(pos);
      println(score);
    };
  }
}

fn test_hamming_distance() -> Unit {
  let seq1 = make_sequence(5);
  seq1.data[0] = A;
  seq1.data[1] = T;
  seq1.data[2] = G;
  seq1.data[3] = C;
  seq1.data[4] = A;
  
  let seq2 = make_sequence(5);
  seq2.data[0] = A;
  seq2.data[1] = T;
  seq2.data[2] = C;
  seq2.data[3] = C;
  seq2.data[4] = G;
  
  let dist = hamming_distance(seq1, seq2);
  println(dist);
}

fn test_motif_finding() -> Unit {
  let seq = make_sequence(15);
  seq.data[0] = A;
  seq.data[1] = T;
  seq.data[2] = G;
  seq.data[3] = A;
  seq.data[4] = T;
  seq.data[5] = G;
  seq.data[6] = C;
  seq.data[7] = A;
  seq.data[8] = T;
  seq.data[9] = G;
  seq.data[10] = T;
  seq.data[11] = A;
  seq.data[12] = T;
  seq.data[13] = G;
  seq.data[14] = A;
  
  let motif = make_sequence(3);
  motif.data[0] = A;
  motif.data[1] = T;
  motif.data[2] = G;
  
  let count = find_motif(seq, motif);
  println(count);
}

fn test_consensus() -> Unit {
  let seq1 = make_sequence(5);
  seq1.data[0] = A;
  seq1.data[1] = T;
  seq1.data[2] = G;
  seq1.data[3] = C;
  seq1.data[4] = A;
  
  let seq2 = make_sequence(5);
  seq2.data[0] = A;
  seq2.data[1] = T;
  seq2.data[2] = C;
  seq2.data[3] = C;
  seq2.data[4] = A;
  
  let seq3 = make_sequence(5);
  seq3.data[0] = A;
  seq3.data[1] = G;
  seq3.data[2] = G;
  seq3.data[3] = C;
  seq3.data[4] = A;
  
  let seqs = [seq1, seq2, seq3];
  let consensus = create_consensus(seqs, 3, 5);
  
  let mut i = 0;
  while i < 5 {
    println(nucleotide_to_int(consensus.data[i]));
    i = i + 1;
  }
}

fn test_alignment_quality() -> Unit {
  let q1 = compute_alignment_quality(95, 100);
  let q2 = compute_alignment_quality(75, 100);
  let q3 = compute_alignment_quality(55, 100);
  let q4 = compute_alignment_quality(35, 100);
  
  println(quality_to_int(q1));
  println(quality_to_int(q2));
  println(quality_to_int(q3));
  println(quality_to_int(q4));
}

fn test_multiple_patterns() -> Unit {
  let seq = make_sequence(20);
  let mut i = 0;
  while i < 20 {
    seq.data[i] = int_to_nucleotide(i % 4);
    i = i + 1;
  }
  
  let p1 = make_sequence(3);
  p1.data[0] = A;
  p1.data[1] = T;
  p1.data[2] = G;
  
  let p2 = make_sequence(3);
  p2.data[0] = G;
  p2.data[1] = C;
  p2.data[2] = A;
  
  let r1 = find_pattern(seq, p1);
  let r2 = find_pattern(seq, p2);
  
  match r1 {
    NoMatch => { println(0); };
    Match(pos, _) => { println(pos); };
  };
  
  match r2 {
    NoMatch => { println(0); };
    Match(pos, _) => { println(pos); };
  };
}

fn main {
  test_complement();
  test_gc_content();
  test_pattern_matching();
  test_hamming_distance();
  test_motif_finding();
  test_consensus();
  test_alignment_quality();
  test_multiple_patterns();
}

