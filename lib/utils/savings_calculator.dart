double getDefaultUsagePerAcre(String broadCategory) {
  switch (broadCategory.toLowerCase()) {
    case 'fertilizers':
      return 10.0;
    case 'microutrients': // sometimes spelled micronutrients
    case 'micronutrients':
      return 1.0;
    case 'pesticides': // assuming similar to fertilizers
      return 10.0;
    default:
      return 1.0;
  }
}

double calculatePerAcreSavings(
    double mrp, double altPrice, double usagePerAcre) {
  double diffPerUnit = mrp - altPrice;
  return diffPerUnit * usagePerAcre;
}
