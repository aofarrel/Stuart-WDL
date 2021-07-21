version 1.0

task stuart_filechecker {
  input {
    File test
    File truth
    Boolean exact = true
    Boolean verbose = true
    Float tolerance = 0.00000001
  }

  command <<<
    md5sum ~{test} > test.txt
    md5sum ~{truth} > truth.txt
    touch "report.txt"

    if cat ~{truth} | md5sum --check test.txt
    then
      echo "Files pass" > report.txt
    else
      if ~{verbose}
      then
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
      else
        if ~{exact}
        then
          echo "Files do not pass" > report.txt
        else
          echo "Calling Rscript to check for functional equivalence."
          if Rscript /opt/rough_equivalence_check.R ~{test} ~{truth} ~{tolerance}
          then
            echo "Outputs are not identical, but are mostly equivalent." > report.txt
          else
            echo "Outputs vary beyond accepted tolerance (default:1.0e-8)." > report.txt
          fi
        fi
      fi
    fi

  >>>

  output {
    File report = "report.txt"
  }

  runtime {
    cpu: 1
    docker: "quay.io/aofarrel/rchecker:1.1.0"
    memory: "1 GB"
    preemptible: 2
  }

}