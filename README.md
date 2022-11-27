<p align="center">
  <h3 align="center"><b>fuzzpm</b></h3>
  <p align="center">Differential Fuzzing for Perl Modules</p>
  <p align="center">
    <a href="https://github.com/htrgouvea/fuzzpm/blob/master/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
    <a href="https://github.com/htrgouvea/fuzzpm/releases">
      <img src="https://img.shields.io/badge/version-0.0.1-blue.svg">
    </a>
  </p>
</p>

---

### Summary

Using Differential Fuzzer to hunt for logic bugs on Perl Modules, full publication is avaible on:
[https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs](https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs)

---

### Download and install

```bash
# Download
$ git clone https://github.com/htrgouvea/fuzzpm && cd fuzzpm

# Install libs and dependencies
$ cpanm --installdeps .
```

---

### Test Cases

---

### Fuzz Target


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