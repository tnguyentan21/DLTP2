Task tsk = new Task();
tsk.Subject = 'Follow up with Lead';
tsk.WhatId = [select Id from Opportunity Limit 1].Id;
//This is the default...
tsk.OwnerId = UserInfo.getUserId();
tsk.Status = 'New';
tsk.Type = 'Call';
insert tsk;