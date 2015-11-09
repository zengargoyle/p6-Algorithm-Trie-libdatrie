use v6;
unit class Algorithm::Trie::libdatrie;
use NativeCall;

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

=end pod

#| for freeing returned key from TrieIterator.key
sub free(CArray[uint32]) is native(Str) { * }

class AlphaMap is repr('CPointer') { }
class TrieState is export is repr('CPointer') { }


class TrieIterator is export is repr('CPointer') {

  method new(TrieState $state) returns TrieIterator {
    trie_iterator_new($state);
  }

  method next() returns Bool {
    trie_iterator_next(self) !== 0;
  }

  method key() returns Str {
    my Str $key;
    my $k = trie_iterator_get_key(self) || fail 'could not get key';
    loop { state $i = 0; last if $k[$i] == 0; $key ~= $k[$i++].chr }
    free($k);
    $key;
  }

  method value() returns Int {
    Int( trie_iterator_get_data(self) );
  }

}

class Trie is export is repr('CPointer') {

  multi method new(**@ranges) returns Trie {
    my AlphaMap $map = alpha_map_new();
    for @ranges -> $range {
      alpha_map_add_range($map, |$range.bounds.map(*.ord)) == 0
        or fail "could not add range: $range";
    }
    my $t = trie_new($map) || fail "could not create trie";
    alpha_map_free($map);
    return $t;
  }

  multi method new(Str $file) returns Trie {
    trie_new_from_file($file) || fail "could not load trie from '$file'"
  }
  
  method save(Str $file) returns Bool {
    trie_save(self,$file) == 0 || fail "could not save trie to '$file'";
  }

  method free() {
    trie_free(self);
  }

  method is-dirty() {
    trie_is_dirty(self);
  }

  method store(Str $key, Int $data) returns Bool {
    my $c = CArray[uint32].new($key.ords, 0);
    trie_store(self, $c, $data) !== 0;
  }

  method store-if-absent(Str $key, Int $data) returns Bool {
    my $c = CArray[uint32].new($key.ords, 0);
    trie_store_if_absent(self, $c, $data) !== 0;
  }

  method retrieve(Str $key) returns Int {
    my $c = CArray[uint32].new($key.ords, 0);
    my $ret = CArray[uint32].new(0);
    my $rc = trie_retrieve(self, $c, $ret);
    return Int($ret[0]) but ($rc ?? True !! False);
  }

  method delete(Str $key) returns Bool {
    my $c = CArray[uint32].new($key.ords, 0);
    trie_delete(self, $c) !== 0;
  }

  method root() returns TrieState {
    trie_root(self) || fail 'state';
  }

  method iterator() returns TrieIterator {
    trie_iterator_new(trie_root(self));
  }

}

#
# AlphaMap
#

sub alpha_map_new() returns AlphaMap
  is native('libdatrie')
  { * }

sub alpha_map_add_range(AlphaMap,int32,int32) returns int32
  is native('libdatrie')
  { * }

sub alpha_map_free(AlphaMap)
  is native('libdatrie')
  { * }

#
# Trie
#

sub trie_new(AlphaMap) returns Trie
  is native('libdatrie')
  { * }

sub trie_new_from_file(Str) returns Trie
  is native('libdatrie')
  { * }

sub trie_save(Trie,Str) returns int32
  is native('libdatrie')
  { * }

sub trie_free(Trie)
  is native('libdatrie')
  { * }

sub trie_store(Trie,CArray[uint32],int32) returns int32
  is native('libdatrie')
  { * }

sub trie_store_if_absent(Trie,CArray[uint32],int32) returns int32
  is native('libdatrie')
  { * }

sub trie_delete(Trie,CArray[uint32]) returns int32
  is native('libdatrie')
  { * }

sub trie_retrieve(Trie,CArray[uint32],CArray[uint32]) returns int32
  is native('libdatrie')
  { * }

sub trie_root(Trie) returns TrieState
  is native('libdatrie')
  { * }

sub trie_is_dirty(Trie) returns uint32
  is native('libdatrie')
  { * }

# TODO: callbacks into Perl 6 make brain hurt.
# sub trie_enumerate(Trie,TrieEnumFunc,Pointer[void]) returns uint32
#   is native('libdatrie')
#   { * }

# XXX: not implemented raw I/O via IO::Handle?
# sub trie_fwrite(Trie,FILE) returns uint32
#   is native('libdatrie')
#   { * }
# sub trie_fread(FILE) returns Trie
#   is native('libdatrie')
#   { * }

#
# TrieIterator
#

sub trie_iterator_new(TrieState) returns TrieIterator
  is native('libdatrie')
  { * }

sub trie_iterator_next(TrieIterator) returns Bool
  is native('libdatrie')
  { * }

sub trie_iterator_get_key(TrieIterator) returns CArray[uint32]
  is native('libdatrie')
  { * }

sub trie_iterator_get_data(TrieIterator) returns uint32
  is native('libdatrie')
  { * }







=begin pod

=head1 SEE ALSO

The datrie library: L<http://linux.thai.net/~thep/datrie/datrie.html>

Wikipedia entry for: L<Trie|http://en.wikipedia.org/wiki/Trie>

=head1 AUTHOR

zengargoyle <zengargoyle@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 zengargoyle

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
