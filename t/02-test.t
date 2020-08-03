use Red;
use RedX::GraphQL;

model Ble {}
model Bla is gql-type {
   has Int $.id         is id     is shared;
   has Str $.name       is column is shared;
   has Str @.somethings is column{ :nullable } is shared;
   has     $.aaa        is relationship(*.id, :model<Ble>) is shared;
}
say Bla.^gql
