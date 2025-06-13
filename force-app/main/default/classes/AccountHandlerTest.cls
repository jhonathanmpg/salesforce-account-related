@isTest
public class AccountHandlerTest {

    // Método de prueba estático
    @isTest
    static void testUpdateAccountRelatedContact() {

        // 1️⃣ Crear cuentas de prueba
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{acc1, acc2}; // Insertamos ambas cuentas

        // 2️⃣ Crear contactos relacionados con esas cuentas
        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc1.Id);
        Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = acc1.Id);
        Contact contact3 = new Contact(FirstName = 'Alice', LastName = 'Brown', AccountId = acc2.Id);
        insert new List<Contact>{contact1, contact2, contact3}; // Insertamos los contactos

        // 3️⃣ Actualizar las cuentas para disparar el trigger (after update)
        acc1.Name = 'Updated Account 1';
        acc2.Name = 'Updated Account 2';
        update new List<Account>{acc1, acc2};

        // 4️⃣ Consultar las cuentas para verificar si el campo personalizado se actualizó
        Account updatedAcc1 = [SELECT Id, Number_of_Contacts__c FROM Account WHERE Id = :acc1.Id];
        Account updatedAcc2 = [SELECT Id, Number_of_Contacts__c FROM Account WHERE Id = :acc2.Id];

        // 5️⃣ Verificaciones (asserts)
        // La primera cuenta tiene 2 contactos
        System.assertEquals(2, updatedAcc1.Number_of_Contacts__c, 'Account 1 should have 2 contacts');

        // La segunda cuenta tiene 1 contacto
        System.assertEquals(1, updatedAcc2.Number_of_Contacts__c, 'Account 2 should have 1 contact');
    }
}
