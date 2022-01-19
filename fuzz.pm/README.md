# Perl Modules Fuzzer


### Introduction

Using Differential Fuzzer to hunt for logic bugs on Perl Modules, full publication avaible on:
[https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs](https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs)

---

### Test Cases


---

### Fuzz Target


---

### Fuzzing

try:

perl fuzzer.pl cases/parsing-url.yml
perl fuzzer.pl cases/json-decode.yml

---

### Conclusion

The idea of this project was to illustrate how simple, fast and powerful the differential fuzzing technique can be, especially in this context to analyze the security of dependencies that are created and maintained by third parties.

---

### References

1. https://heitorgouvea.me/2021/12/08/Differential-Fuzzing-Perl-Libs
2. https://en.wikipedia.org/wiki/Differential_testing
3. https://www.blackhat.com/docs/us-17/thursday/us-17-Tsai-A-New-Era-Of-SSRF-Exploiting-URL-Parser-In-Trending-Programming-Languages.pdf
4. https://bishopfox.com/blog/json-interoperability-vulnerabilities