version 1.0

task stuart_filechecker {
  input {
    File test
    File truth
    Boolean exact = true
    Boolean verbose = true
    Float tolerance = 0.00000001

    Int disk_size = 5  # in gigabytes
  }

  command <<<
    md5sum ~{test} > test.txt
    md5sum ~{truth} > truth.txt
    touch "report.txt"

    if cat ~{truth} | md5sum --check test.txt
    then
      echo "Files pass" | tee -a report.txt
    else
      if ~{verbose}
      then
        echo "Test checksum:" | tee -a report.txt
        cat test.txt | tee -a report.txt
        echo "Truth checksum:" | tee -a report.txt
        cat truth.txt | tee -a report.txt
        echo "-=-=-=-=-=-=-=-=-=-\nContents of test file:" | tee -a report.txt
        cat ~{test} | tee -a report.txt
        echo "-=-=-=-=-=-=-=-=-=-\nContents of truth file:" | tee -a report.txt
        cat ~{truth} | tee -a report.txt
        echo "-=-=-=-=-=-=-=-=-=-\ncmp and diff of files:" | tee -a report.txt
        cmp --verbose test.txt truth.txt | tee -a report.txt
        diff test.txt truth.txt | tee -a report.txt
        diff -w test.txt truth.txt
      else
        if ~{exact}
        then
          echo "Files do not pass md5sum check" | tee -a report.txt
        else
          echo "Calling Rscript to check for functional equivalence..."
          if Rscript /opt/rough_equivalence_check.R ~{test} ~{truth} ~{tolerance}
          then
            echo "Outputs are not identical, but are mostly equivalent." | tee -a report.txt
          else
            echo "Outputs vary beyond accepted tolerance (default:1.0e-8)." | tee -a report.txt
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
    disks: "local-disk " + disk_size + " HDD"
    docker: "quay.io/aofarrel/rchecker:1.1.0"
    memory: "1 GB"
    preemptible: 2
  }

}