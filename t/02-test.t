use Red;
use RedX::GraphQL;
use Test;

model Ble {}
model Bla is gql-type {
   has Int $.id         is id     is shared;
   has Str $.name       is column is shared;
   has Str @.somethings is column{ :nullable } is shared;
   has     $.aaa        is relationship(*.id, :model<Ble>) is shared;
}
is Bla.^gql, Q:to/END/;
type Bla {
    id: ID!
    name: String!
    somethings: [String]
    aaa: Ble
}
END
done-testing
