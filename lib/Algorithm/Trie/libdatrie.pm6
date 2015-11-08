use v6;
unit class Algorithm::Trie::libdatrie;


=begin pod

=head1 NAME

Algorithm::Trie::libdatrie - a character keyed trie using the L<datrie|http://linux.thai.net/~thep/datrie/datrie.html> library.

=head1 SYNOPSIS

  use Algorithm::Trie::libdatrie;

  my Trie $t .= new: 'a'..'z', 'A'..'Z';
  my @words = <pool prize preview prepare produce progress>;
  for @words:kv -> $data, $word {
    $t.store( $word, $data );
  }
  $data = $t.retrieve($word);
  my $iter = $t.iterator;
  while $iter.next {
    $key = $iter.key;
    $data = $iter.value;
  }

=head1 DESCRIPTION

Algorithm::Trie::libdatrie is an implementation of a character keyed L<trie|http://en.wikipedia.org/wiki/Trie> using the L<datrie|http://linux.thai.net/~thep/datrie/datrie.html> library.

As the author of the datrie library states:

=begin quote

Trie is a kind of digital search tree, an efficient indexing method with
O(1) time complexity for searching. Comparably as efficient as hashing,
trie also provides flexibility on incremental matching and key spelling
manipulation. This makes it ideal for lexical analyzers, as well as
spelling dictionaries.

This library is an implementation of double-array structure for representing
trie, as proposed by Junichi Aoe. The details of the implementation can be
found at L<http://linux.thai.net/~thep/datrie/datrie.html>

=end quote

Trie: .store, .delete, .retrieve, .enumerate

Trie.root --> TrieState: .walk, .rewind, .clone, trie_state_copy(),
.is_walkable, .walkable_chars, .is_single, .value

Trie.iterator --> TrieIterator: .next, .key, .value.

=head1 SEE ALSO

The datrie library: L<http://linux.thai.net/~thep/datrie/datrie.html>

Wikipedia entry for: L<Trie|http://en.wikipedia.org/wiki/Trie>

=head1 AUTHOR

zengargoyle <zengargoyle@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 zengargoyle

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
