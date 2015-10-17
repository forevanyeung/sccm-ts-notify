# sccm-ts-notify
Send notification emails upon completion of a tasksequence

Instructions
1. Copy sccm_ts_notify.ps1 to a location on the primary SCCM server
2. Navigate to Administration > Site Configuration > Sites in Configuration Manager
3. Select the appropriate site and right-click > Status Filter Rules
4. Click Create and name the new status filter rule
5. Check Message ID and type in 11171, click Next
6. Check Report to the event log and Run a program, type in C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -file C:\PathTo\sccm_ts_notify.ps1 -MachineName %msgsys -Success
7. Click Next, Next, Close
8. Repeat Steps 4 - 7, to create a new status filter for failed task sequences. This time for Message ID use 11170 and replace -Success with -Fail
