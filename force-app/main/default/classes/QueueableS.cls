
public with sharing class QueueableS implements Queueable {
    
    public static void execute(QueueableContext qc) {
        List<Account> accounts = [
            SELECT Id, Description
            FROM Account
            LIMIT 1000
        ];
        for (Account acct : accounts) {
            acct.Description += ' Edited by Queueable class';
        }
        try {
            update accounts;
        } catch (DmlException dmle) {
            System.debug(
                LoggingLevel.INFO,
                'logging the error: ' +
                dmle.getMessage()
            );
        }
    }
}
