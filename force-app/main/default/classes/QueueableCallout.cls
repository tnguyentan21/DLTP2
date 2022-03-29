
public with sharing class QueueableCallout implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static Boolean throwError = false;
    @testVisible
    private static Boolean circuitBreakerThrown = false;

    
    public class QueueableCallout extends Exception {
    }

    
    public static void execute(QueueableContext qc) {
        HttpResponse response = RestClient.makeApiCall(
            'mockBin',
            RestClient.HttpVerb.GET,
            '/'
        );
        List<Account> accounts = [
            SELECT Id
            FROM Account
            ORDER BY Id
            LIMIT 1000
        ];
        for (Account acct : accounts) {
            acct.Description = String.valueOf(response.getStatusCode());
        }
        if (Test.isRunningTest() && throwError) {
            accounts = (List<Account>) TestFactory.invalidateSObjectList(
                accounts
            );
        }

        try {
            update accounts;
        } catch (DmlException dmle) {
            System.debug(
                LoggingLevel.INFO,
                'logging the error: ' +
                dmle.getMessage()
            );
            if (Test.isRunningTest()) {
                QueueableCallout.circuitBreakerThrown = true;
            }
        }
    }
}
