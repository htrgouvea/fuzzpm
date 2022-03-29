<p align="center">
  <h3 align="center">Fuzz.pm</h3>
  <p align="center">Simple fuzzer PoC for Perl Modules</p>
</p>

---

### Introduction

Using Differential Fuzzer to hunt for logic bugs on Perl Modules, full publication is avaible on:
[https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs](https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs)

---

### Test Cases


---

### Fuzz Target


---

### Fuzzing

try:

```bash
$ perl fuzzer.pl cases/json-decode.yml
$ perl fuzzer.pl cases/parsing-url.yml
```

---

### Conclusion

The idea of this project was to illustrate how simple, fast and powerful the differential fuzzing technique can be, especially in this context to analyze the security of dependencies that are created and maintained by third parties.

---

### References

1. https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs