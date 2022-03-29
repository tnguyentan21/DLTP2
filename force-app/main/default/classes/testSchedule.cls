@istest
class TestClass {

   static testmethod void test() {
   Test.startTest();

      Account a = new Account();
      a.Name = 'testScheduledApexFromTestMethod';
      insert a;

   

      String jobId = System.schedule('testBasicScheduledApex',
      TestScheduledApexFromTestMethod.CRON_EXP, 
         new TestScheduledApexFromTestMethod());

      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      System.assertEquals(TestScheduledApexFromTestMethod.CRON_EXP, 
         ct.CronExpression);

      System.assertEquals(0, ct.TimesTriggered);

      System.assertEquals('2022-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));
      System.assertNotEquals('testScheduledApexFromTestMethodUpdated',
         [SELECT id, name FROM account WHERE id = :a.id].name);

   Test.stopTest();

   System.assertEquals('testScheduledApexFromTestMethodUpdated',
   [SELECT Id, Name FROM Account WHERE Id = :a.Id].Name);

   }
}