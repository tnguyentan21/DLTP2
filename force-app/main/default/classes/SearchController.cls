public with sharing class SearchController {
    public SearchController() {
        @AuraEnabled(Cacheable = true)
        public static List<Product2> retriveProducts(String strProdName) {
            strProdName = '%' + strProdName + '%';
            List<Product3> lstProd = [SELECT  Id, Name, ProductCode FROM Product2 WHERE Name LIKE :strProdName];
            return lstProd; 
        }
    }
}
