# Salesforce Account Related Contacts Counter

## Exercise Description

The objective of this project is to **automatically count the number of related contacts** every time an account is updated in Salesforce, and store this value in a custom field called `Number_of_Contacts__c`.

## Problem to Solve

- When an account is updated, we need to count how many contacts are related to that account
- The result must be stored in the custom field `Number_of_Contacts__c` (numeric type)
- The solution must be automatic and efficient

## Solution Architecture

### 1. Project Structure

```
├── force-app/main/default/
│   ├── classes/
│   │   ├── AccountHandler.cls          # Main business logic
│   │   ├── AccountHandlerTest.cls      # Unit tests
│   │   ├── AccountHelper.cls           # Helper class (if exists)
│   │   └── TriggerHelper.cls           # Recursion control
│   └── triggers/
│       └── UpdateAccountContactCount.trigger  # Main trigger
├── scripts/apex/
│   └── updateAllAccounts.apex          # Script for existing accounts
└── manifest/
    └── package.xml                     # Deployment manifest
```

### 2. Main Components

#### **AccountHandler.cls**
- Contains the main logic for counting contacts
- Uses aggregate SOQL queries to optimize performance
- Updates multiple accounts in a single DML operation

#### **UpdateAccountContactCount.trigger**
- Executes after inserting or updating accounts (`after insert`, `after update`)
- Includes recursion control to prevent infinite loops
- Calls the `AccountHandler` class to process accounts

#### **TriggerHelper.cls**
- Controls recursive trigger execution
- Prevents "maximum trigger depth exceeded" error

#### **AccountHandlerTest.cls**
- Complete unit tests
- Verifies trigger and handler class functionality
- Ensures adequate code coverage

## Features

✅ **Automatic counting**: Every time an account is updated, the number of related contacts is automatically counted

✅ **Performance optimization**: Uses aggregate SOQL queries (`GROUP BY`) to efficiently process multiple accounts

✅ **Recursion control**: Prevents infinite loops in triggers

✅ **Unit testing**: Includes complete tests to ensure functionality

✅ **Script for existing accounts**: Allows updating all existing accounts in the org

## Installation and Setup

### Prerequisites

1. Salesforce CLI installed
2. Salesforce org with administrator permissions
3. Custom field `Number_of_Contacts__c` created on the Account object

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd AccountRelated
   ```

2. **Authenticate to Salesforce**:
   ```bash
   sfdx force:auth:web:login -a YourOrgAlias
   ```

3. **Deploy components**:
   ```bash
   sf project deploy start --target-org YourOrgAlias --ignore-conflicts
   ```

4. **Run tests**:
   ```bash
   sfdx force:apex:test:run -c -r human --target-org YourOrgAlias
   ```

## Update Existing Accounts

To update all accounts that already exist in your org with the correct number of contacts, run the following script:

### Option 1: Using Salesforce CLI

```bash
sfdx force:apex:execute -f scripts/apex/updateAllAccounts.apex --target-org YourOrgAlias
```

### Option 2: From Developer Console

1. Open Developer Console in your Salesforce org
2. Go to Debug > Open Execute Anonymous Window
3. Copy and paste the following code:

```apex
// Script to update all existing accounts
List<Account> allAccounts = [SELECT Id FROM Account];
Set<Id> allAccountIds = new Set<Id>();

for (Account acc : allAccounts) {
    allAccountIds.add(acc.Id);
}

System.debug('Total accounts to process: ' + allAccountIds.size());

if (!allAccountIds.isEmpty()) {
    try {
        AccountHandler.updateAccountRelatedContact(allAccountIds);
        System.debug('✅ Update completed successfully for ' + allAccountIds.size() + ' accounts');
    } catch (Exception e) {
        System.debug('❌ Error during update: ' + e.getMessage());
    }
}
```

4. Click "Execute"

## Usage

Once installed, the system works automatically:

1. **Account creation**: When inserting a new account, the number of contacts is automatically calculated (0 initially)
2. **Account update**: When modifying any field of an account, the number of related contacts is recalculated
3. **Contact creation/deletion**: Changes will be reflected the next time the account is updated

## Code Structure

### Required Custom Field

- **Name**: Number of Contacts
- **API Name**: `Number_of_Contacts__c`
- **Type**: Number(18,0)
- **Object**: Account

### SOQL Query Used

```sql
SELECT AccountId, COUNT(Id) contactCount
FROM Contact
WHERE AccountId IN :accountIds
GROUP BY AccountId
```

## Testing

The project includes complete unit tests in `AccountHandlerTest.cls`. To run the tests:

```bash
sfdx force:apex:test:run -c -r human --target-org YourOrgAlias
```

The tests verify:
- ✅ Correct contact count per account
- ✅ Automatic update of custom field
- ✅ Handling accounts without contacts (value = 0)
- ✅ Processing multiple accounts

## Technical Considerations

- **Governor Limits**: Code respects Salesforce limits using aggregate queries
- **Bulkification**: Designed to handle multiple records in a single transaction
- **Recursion Control**: Includes mechanisms to prevent infinite loops
- **Error Handling**: Implements try-catch to capture and handle exceptions

## How It Works

1. **Trigger Execution**: When an account is updated, the `UpdateAccountContactCount` trigger fires
2. **Recursion Check**: The trigger checks if it's already running to prevent infinite loops
3. **ID Collection**: Account IDs are collected from the trigger context
4. **Contact Counting**: The `AccountHandler.updateAccountRelatedContact()` method:
   - Executes an aggregate SOQL query to count contacts per account
   - Creates a map of AccountId → Contact Count
   - Updates the `Number_of_Contacts__c` field for each account
5. **DML Operation**: All account updates are performed in a single DML operation

## Key Code Snippets

### Trigger Logic
```apex
trigger UpdateAccountContactCount on Account (after insert, after update) {
    if (TriggerHelper.isAccountTriggerRunning) {
        return;
    }
    
    TriggerHelper.isAccountTriggerRunning = true;
    
    try {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : Trigger.new) {
            accountIds.add(acc.Id);
        }
        
        AccountHandler.updateAccountRelatedContact(accountIds);
    } finally {
        TriggerHelper.isAccountTriggerRunning = false;
    }
}
```

### Contact Counting Logic
```apex
public static void updateAccountRelatedContact(Set<Id> accountIds) {
    Map<Id, Integer> contactCountMap = new Map<Id, Integer>();
    
    for (AggregateResult ar : [
        SELECT AccountId, COUNT(Id) contactCount
        FROM Contact
        WHERE AccountId IN :accountIds
        GROUP BY AccountId
    ]) {
        contactCountMap.put(
            (Id) ar.get('AccountId'),
            (Integer) ar.get('contactCount')
        );
    }
    
    List<Account> accountsToUpdate = new List<Account>();
    for (Id accId : accountIds) {
        Integer cnt = contactCountMap.containsKey(accId) ? 
                     contactCountMap.get(accId) : 0;
        accountsToUpdate.add(new Account(
            Id = accId,
            Number_of_Contacts__c = cnt
        ));
    }
    
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
```

## Author

Project developed to automate the counting of related contacts in Salesforce accounts.

## License

This project is under the MIT License.