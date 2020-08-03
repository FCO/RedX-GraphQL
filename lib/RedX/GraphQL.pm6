use v6.c;

role RedX::GraphQL::Attr {
	has Bool $.gql-shared;
}

role RedX::GraphQL {
	my enum TranslationTypes <type required>;
	has Str $.gql-name;
	multi method gql-type($model where { defined $.gql-name }) { self.gql-name }
	multi method gql-type($model)                              { $model.^name  }
	method gql($model) {
		qq:to/END/;
		type { self.gql-type: $model } \{
		{
			$model.^attributes.grep({ .?gql-shared // False }).map({
				"{ .?column.?attr-name // .name.substr: 2 }: { $.translate($_, type) }{ $.translate($_, required) }"
			}).join("\n").indent: 4
		}
		\}
		END
	}

	multi method translate-type("Str")         { "String"    }
	multi method translate-type(Positional $_) { "[{ self.translate-type: .of }]" }
	multi method translate-type(Str:U)         { "String"    }
	multi method translate-type(Str:D $type)   { $type       }
	multi method translate-type(Mu:U $type)    { $type.^name }

	multi method translate(RedX::GraphQL::Attr $  where { .?column.id                  }, type) { "ID"                                     }
	multi method translate(RedX::GraphQL::Attr $_ where { .^can("relationship-model")  }, type) { self.translate-type: .relationship-model }
	multi method translate(RedX::GraphQL::Attr $_ where { .?column.?model-name         }, type) { self.translate-type: .column.model-name  }
	multi method translate(RedX::GraphQL::Attr $_ where { !.^can("relationship-model") }, type) { self.translate-type: .type               }

	multi method translate(RedX::GraphQL::Attr $ where .?column.?nullable === False, required) { "!" }
	multi method translate(RedX::GraphQL::Attr $, required)                                    { ""  }

}

multi trait_mod:<is>(Mu $m, Bool :$gql-type where $_ === True) is export {
	$m.HOW does RedX::GraphQL
}

multi trait_mod:<is>(Mu $m, Str :$gql-type) is export {
	$m.HOW does RedX::GraphQL($gql-type)
}

multi trait_mod:<is>(Attribute $a, Bool :$shared where $_ === True) is export {
	$a does RedX::GraphQL::Attr($shared)
}

#augment class Red::Schema {
#	method graphQL {
#		qq:to/END/;
#		schema \{
#		{
#			self.models.kv.map(-> $name, $model {
#			}).join: "\n"
#		}
#		\}
#		END
#	}
#}

=begin pod

=head1 NAME

RedX::GraphQL - GraphQL plugin for Rex ORM

=head1 SYNOPSIS

=begin code :lang<perl6>

use RedX::GraphQL;

=end code

=head1 DESCRIPTION

RedX::GraphQL is ...

=head1 AUTHOR

Fernando Corrêa de Oliveira <fernando.correa@humanstate.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
