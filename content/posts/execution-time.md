---
title: Execution time
date: 2020-04-30
---

Consider this Python program:

```python3
# num_add.py

ans = 0

for i in range(123456789):
    ans += 1

print(ans)
```

It runs in a little over 10 seconds:

```console
$ time python num_add.py
123456789

real    0m12.896s
user    0m12.868s
sys     0m0.008s
```

This result is expected; it takes a certain amount of time to perform more than
one hundred million additions. During this, my computer was working hard; the
fans started going pretty fast.

Now consider this Python program:

```python3
# sleep.py

import time

time.sleep(12.8)

print(123456789)
```

It executes in about the same amount of time and outputs the same thing:

```console
$ time python sleep.py
123456789

real    0m12.847s
user    0m0.026s
sys     0m0.008s
```

This time though, my computer was completely silent during the execution. As if
nothing was being done. If you look at the source of [`time.sleep`], and to the
called cross platform [`pysleep`] function, you will see that the underlying
mechanism for wasting time is a call to [`select`] with no watched file
descriptor sets and the desired timeout. From this point, it is up to the
operating system to return when the amount of time is elapsed.

The actual CPU time can be seen in the values returned by the [`time`] command.
The `user` and `sys` parts is the time that was taken for running code in
user-mode and in kernel-mode respectively. The first program spent all the time
running code whereas the second spent almost no time running code. While they
have the same behavior, it could be argued that the second script is better
since it leaves CPU time for the OS to perform more important tasks.

[`time.sleep`]: https://github.com/python/cpython/blob/62183b8d6d49e59c6a98bbdaa65b7ea1415abb7f/Modules/timemodule.c#L326
[`pysleep`]: https://github.com/python/cpython/blob/62183b8d6d49e59c6a98bbdaa65b7ea1415abb7f/Modules/timemodule.c#L1859
[`select`]: https://linux.die.net/man/3/select
[`time`]: https://linux.die.net/man/1/time

We will now test out a similar program in C:

```c
// num_add.c

#include <stdio.h>

int main() {
    int ans = 0;

    for (int i=0; i<123456789; i++) {
        ans += 1;
    }

    printf("%d\n", ans);
}
```

This one has a more surprising execution time:

```console
$ gcc num_add.c
$ time ./a.out
123456789

real    0m0.296s
user    0m0.294s
sys     0m0.002s
```

The computation time is a fraction of a second. At first, I was certain a
compiler optimization had avoided the computation and just printed the obvious
result. By inspecting the Assembly for this program, we can see that the loop
and arithmetic is actually performed:

```asm
...
40113e:       83 45 fc 01             addl   $0x1,-0x4(%rbp)
401142:       83 45 f8 01             addl   $0x1,-0x8(%rbp)
401146:       81 7d f8 14 cd 5b 07    cmpl   $0x75bcd14,-0x8(%rbp)
40114d:       7e ef                   jle    40113e <main+0x18>
...
```

I was aware of overhead in interpreted languages such as Python but never
thought it would be this obvious.

This simple experiment shows how execution time varies in very similar programs.
I would much prefer waiting only 0.2 seconds rather than 12 for my computations
to complete. At the same time, I would choose writing in a higher level
programming language any day. As with many other things in life, it is a matter
of tradeoffs.
