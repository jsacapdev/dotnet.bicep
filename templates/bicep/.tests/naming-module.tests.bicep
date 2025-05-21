
// Test with only required parameters
module test_required_params '../naming-module.bicep' = {
  name: 'test_required_params'
  params: {
    environment: 'test'
    region: 'westeu'
    workload: 'workload'
  }
}
