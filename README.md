<p align="center">
  <h3 align="center"><b>FuzzPM</b></h3>
  <p align="center">Differential Fuzzing for Perl Modules</p>
  <p align="center">
    <a href="https://github.com/htrgouvea/fuzzpm/blob/master/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
    <a href="https://github.com/htrgouvea/fuzzpm/releases">
      <img src="https://img.shields.io/badge/version-0.0.2-blue.svg">
    </a>
  </p>
</p>

---

### Summary

This project aims to demonstrate how we can use the differential fuzzing technique to conduct security analysis in an automated and large-scale way to find security issues in modern components used by applications developed in Perl. Full publication is avaible on: [https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs](https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs)

---

### Download and install

```bash
# Download
$ git clone https://github.com/htrgouvea/fuzzpm && cd fuzzpm

# Install libs and dependencies
$ cpanm --installdeps .
```

---

### How it works

Differential fuzzing is an approach where we have our seeds being sent to two or more inputs, where they are consumed and should produce the same output. At the end of the test these outputs are compared, in case of divergence the fuzzer will signal a possible failure. [[1]](#references)

So basically we have 3 components:

- Our targets;
- Input seeds;
- Test cases;

Here is a introduction about how you can create your own targets, seeds and test cases.

Creating a new target:

```perl
package Mojo_URI {
    use strict;
    use warnings;
    use Try::Tiny;
    use Mojo::URL;

    sub new {
        my ($self, $payload) = @_;

        try {
            my $url = Mojo::URL -> new($payload);
            
            return $url -> host;
        }

        catch {
            return undef;
        }
    }
}
```

Store at: ./targets/your-taget-name.pm

Seeds:

./seeds/your-file-name.txt

One data per line


Creating a new test case:

```
```

./cases/your-file-name.yml

---

### Fuzzing

try:

```bash
$ perl fuzzer.pl --case cases/json-decode.yml
$ perl fuzzer.pl --case cases/parsing-url.yml
```


---

### Docker container

```
$ docker build -t fuzzpm .
$ docker run -ti --rm fuzzpm --help
```

---

### Contribution

- Your contributions and suggestions are heartily ♥ welcome. [See here the contribution guidelines.](/.github/CONTRIBUTING.md) Please, report bugs via [issues page](https://github.com/htrgouvea/fuzzpm/issues) and for security issues, see here the [security policy.](/SECURITY.md) (✿ ◕‿◕)

- If you are interested in providing financial support to this project, please visit: [heitorgouvea.me/donate](https://heitorgouvea.me/donate)

---

### License

- This work is licensed under [MIT License.](/LICENSE.md)

---

### References

- [1] [https://en.wikipedia.org/wiki/Differential_testing](https://en.wikipedia.org/wiki/Differential_testing);