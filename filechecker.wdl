version 1.0

task stuart_filechecker {
  input {
    File test
    File truth
    Boolean exact = true
    Boolean verbose = true
  }

  command <<<

    md5sum ~{test} > test.txt
    md5sum ~{truth} > truth.txt

    if ~{verbose}
    then
      # not all backends support optional outputs, 
      # so for now, this goes to stderr rather
      # than an output file
      >&2 echo "Test checksum:"
      >&2 cat test.txt
      >&2 echo "-=-=-=-=-=-=-=-=-=-"
      >&2 echo "Truth checksum:"
      >&2 cat truth.txt
      >&2 echo "-=-=-=-=-=-=-=-=-=-"
      >&2 echo "Contents of the output file:"
      >&2 cat ~{test}
      >&2 echo "-=-=-=-=-=-=-=-=-=-"
      >&2 echo "Contents of the truth file:"
      >&2 cat ~{truth}
      >&2 echo "-=-=-=-=-=-=-=-=-=-"
      >&2 echo "cmp and diff of these files:"
      >&2 cmp --verbose test.txt truth.txt
      >&2 diff test.txt truth.txt
      >&2 diff -w test.txt truth.txt
    fi

    cat ~{truth} | md5sum --check test.txt

  >>>

  runtime {
    docker: "python:3.8-slim"
    preemptible: 2
  }

}