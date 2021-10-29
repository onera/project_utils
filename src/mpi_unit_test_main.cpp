#define DOCTEST_CONFIG_IMPLEMENT
#include "doctest/extensions/doctest_mpi.h"

int main(int argc, char** argv) {
  int provided_thread_support;
  MPI_Init_thread(&argc, &argv, MPI_THREAD_MULTIPLE, &provided_thread_support);
  if (provided_thread_support!=MPI_THREAD_MULTIPLE) {
    std::string s;
    if (provided_thread_support==MPI_THREAD_SINGLE) s = "MPI_THREAD_SINGLE";
    if (provided_thread_support==MPI_THREAD_FUNNELED) s = "MPI_THREAD_FUNNELED";
    if (provided_thread_support==MPI_THREAD_SERIALIZED) s = "MPI_THREAD_SERIALIZED";
    std::cout << "WARNING: MPI_THREAD_MULTIPLE was asked, but only " + s + " was provided\n";
  }

  doctest::Context ctx;
  ctx.setOption("reporters", "MpiConsoleReporter");
  ctx.setOption("reporters", "MpiFileReporter");
  ctx.setOption("force-colors", true);
  ctx.applyCommandLine(argc, argv);

  int test_result = ctx.run();

  MPI_Finalize();

  return test_result;
}
