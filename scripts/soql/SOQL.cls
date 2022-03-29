
public with sharing class SOQLRecipes {
    /**
     * List<Account> results = SOQLRecipes.querySingleObject();
     * System.debug(results);
     **/
    public static List<Account> getRecords() {
        List<Account> accounts = new List<Account>();
        accounts = [
            SELECT Name, ShippingStreet, ShippingCity
            FROM Account
            WITH SECURITY_ENFORCED
        ];
        return accounts;
    }


    public static Integer getLargeNumberOfRecords() {
        Integer count = 0;


        for (Account acct : [SELECT Name FROM Account WITH SECURITY_ENFORCED]) {
            count++;
        }
        return count;
    }


    public static Integer[] getChunksOfLargeNumbersOfRecords() {
        Integer countOfChunks = 0;
        Integer recordCount = 0;

        for (List<Account> accounts : [
            SELECT Name
            FROM Account
            WITH SECURITY_ENFORCED
        ]) {
            countOfChunks += 1;
            recordCount += accounts.size();
        }
        return new List<Integer>{ countOfChunks, recordCount };
    }

    public static List<Account> getRecordsByFieldValue() {
        return [
            SELECT Name
            FROM Account
            WHERE ShippingCountry = 'UK'
            WITH SECURITY_ENFORCED
        ];
    }


    public static List<Account> getRecordsByMultipleFieldValues() {
        return [
            SELECT Name
            FROM Account
            WHERE
                ShippingCountry = 'US'
                AND ShippingState = 'IN'
                AND (Industry = 'Fast Food - made whole'
                OR Industry = 'Slow Food - Made quickly')
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<Account> getSpecificNumberOfRecords() {
        //LIMIT clause
        return [
            SELECT Name
            FROM Account
            WITH SECURITY_ENFORCED
            ORDER BY Industry DESC
            LIMIT 10
        ];
    }


    public static List<Account> getFirstXRecords(Integer wantedNumberOfRows) {
        return [
            SELECT Name
            FROM Account
            WITH SECURITY_ENFORCED
            ORDER BY Industry DESC
            LIMIT :wantedNumberOfRows
        ];
    }


    public static List<Account> getAccountRecordsInState(String state) {
        return [
            SELECT Name
            FROM Account
            WHERE ShippingState = :state
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<Account> getSecond10AccountRecords() {
        return [
            SELECT Id
            FROM Account
            WITH SECURITY_ENFORCED
            ORDER BY Industry DESC
            LIMIT 10
            OFFSET 10
        ];
    }


    public static List<Account> getRecordsWithRelatedRecords() {
        return [
            SELECT Name, (SELECT Name, AccountId FROM Contacts)
            FROM Account
            WITH SECURITY_ENFORCED
        ];
    }

 
    public static List<Contact> getParentRecordDetailsFromChildRecord() {
        return [
            SELECT Id, Name, Email, Account.Name, Account.ShippingState
            FROM Contact
            WHERE Account.ShippingState = 'KS'
            WITH SECURITY_ENFORCED
        ];
    }

  
    public static List<Junction__c> getDetailsFromBothParentRecords() {
        return [
            SELECT Id, parent1__r.Name, Parent2__r.Name
            FROM Junction__c
            WITH SECURITY_ENFORCED
        ];
    }

    
    public static Double getSumOfOpportunityRecords(Id accountId) {
        List<AggregateResult> groupedResults = [
            SELECT SUM(Amount) total
            FROM Opportunity
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
        ];
        return (Double) groupedResults[0].get('total');
    }
}