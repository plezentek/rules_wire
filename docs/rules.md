<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#wire_injector"></a>

## wire_injector

<pre>
wire_injector(<a href="#wire_injector-name">name</a>, <a href="#wire_injector-deps">deps</a>, <a href="#wire_injector-srcs">srcs</a>)
</pre>


Wire is a code generation tool that automates connecting components using
[dependency injection](https://en.wikipedia.org/wiki/Dependency_injection).

Example:
```
    wire_injector(
        name = "product_injector",
        srcs = [
            "main.go",
            "wire.go",
        ],
    )
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| deps |  Packages this injector depends on   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| srcs |  The source files in the package of this injector   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |


