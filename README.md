# NAME

filtered - Apply source filter on external module

# SYNOPSIS

    # Apply source filter YourFilter.pm on Target.pm, then result can be used as FilteredTarget
    # PPI is used for package name replacement specified by C<as>
    use filtered by => 'YourFilter', as => 'FilteredTarget', on => 'Target', use_ppi => 1, qw(func);
    my $obj = FilteredTarget->new;

    # You can omit `as' option and `on' key
    use filtered by => 'YourFilter', 'Target', qw(func);
    my $obj = Target->new; # Target is filtered

    # You can use differnt module with the same filter
    use filtered by => 'YourFilter', as => 'FilteredTarget1', on => 'Target1', qw(func);
    use filtered by => 'YourFilter', as => 'FilteredTarget2', on => 'Target2', qw(func);

    # or, you can also use differnt filters on the same module
    use filtered by => 'YourFilter1', as => 'FilteredTarget1', on => 'Target', qw(func);
    use filtered by => 'YourFilter2', as => 'FilteredTarget2', on => 'Target', qw(func);

    # If you need to pass some arguments to source filter, you can use `with' option
    # NOTE that this is just a scalar string.
    use filtered by => 'YourFilter', with => 'qw(foo bar)', as => 'FilteredTarget', on => 'Target', qw(func);

# DESCRIPTION

Source filter has unlimited power to enhance Perl.
However, source filter is usually applied on your own sources.
This module enables you to apply source filter on external module.

# OPTIONS

Rest of the options are passed to `import` of filtered module.

- `by`

Mandatory. Specify a source filter module you want to apply on an external module.

- `with`

Specify arguments passed to source filter.  NOTE that this value is just embedded as a scalar string.

- `as`

Specify the package name for the resultant filtered module.
This option can be omitted. If omitted, original names are used.

- `on`

Mandatory. Specify a target module. `on` keyword can be ommited if this is the last option.

- `use_ppi`

If true, [PPI](http://search.cpan.org/perldoc?PPI) is used for replacement by `as`. If PPI is available, defaults to true. Otherwise false.

# CAVEATS

- This module uses @INC hook.

For @INC hook, please consult `perldoc -f require`. Hook itself is enabled in short period but it may affect other modules.

- Replacement by `as` is applied in limited context.

If you specified `as => FilteredTarget, on => Target`, the following codes:

    package Target::work;
    package Target;
    Target::work::call();

are transformed into as follows:

    package FilteredTarget::work;
    package FilteredTarget;
    FilteredTarget::work::call();

Actually, only `'\bpackage\s+Target\b'` and `'\bTarget::\b'` are replaced if `use_ppi` is false. `'\bTarget\b'` in arguments of `package` statements and bare words are replaced if `use_ppi` is true.

# SEE ALSO

- [http://github.com/yak1ex/filtered](http://github.com/yak1ex/filtered) - Github repository
- [Filter::Simple](http://search.cpan.org/perldoc?Filter::Simple) - Helper module to implement source filter

# AUTHOR

Yasutaka ATARASHI <yakex@cpan.org>

# LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
