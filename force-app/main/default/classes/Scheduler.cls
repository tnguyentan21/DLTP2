global class scheduledMerge implements Schedulable {
   global void execute(SchedulableContext SC) {
      mergeNumbers M = new mergeNumbers(); 
   }
}

global class scheduledBatchable implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchable b = new batchable(); 
      database.executebatch(b);
   }
}

CronTrigger ct = 
    [SELECT TimesTriggered, NextFireTime
    FROM CronTrigger WHERE Id = :jobID];

CronTrigger job = 
    [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType 
    FROM CronTrigger ORDER BY CreatedDate DESC LIMIT 1];

CronJobDetail ctd = 
    [SELECT Id, Name, JobType 
    FROM CronJobDetail WHERE Id = :job.CronJobDetail.Id];

