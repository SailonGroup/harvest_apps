# CentOS 6.5 Linux VM on Windows Azure with Reserved Public IP Address

The documentation for Windows Azure, in my opinion, is garbage. This is a quick tutorial that allows you to install a CentOS 6.5 Linux VM on Azure using a Reserved Public IP Address. The tutorial is based on an installation made from a Windows 8 laptop.

## Subscribe

You can subscribe directly at http://azure.microsoft.com/. In our case we are using Office 365 and we enabled the Azure Active Directory (which *is not* the equivalent of Windows Server Active Directory) - this provides us with SSO (Single Sign-On).

## Provisioning via Web Portal vs Azure PowerShell

Azure will give you 5 *used* Reserved Public IP Addresses for free (p.s. note the used in bold... if you reserve an IP and don't use it you will be charged for it...). If you want to make use of such Reserved Public IP Addresses, you *will need* to do the whole thing via Azure PowerShell.

*We shall focus the tutorial on an installation with a Reserved Public IP Address.*

If not just do the configurations via the Web Portal at https://manage.windowsazure.com/. This tutorial is based on the old (existing) and not the new (preview) Web Portal.

## Requirements

1. Azure PowerShell and Tools.
2. Storage - this is where your virtual machine disks shall reside.
3. Certificates - you will need to create a key pair which will be installed on your CentOS 6.5 Linux VM.
4. Cloud Service - in layman's terms, this is a private network which resides behind a firewall (sort of).
5. CentOS 6.5 Linux VM - this is where you will place your stuff.

### Azure PowerShell and Tools

Go to http://azure.microsoft.com/en-us/downloads/ and install the following.

1. Azure PowerShell
2. Azure Command Line Tools
3. .NET Framework

You will need to reboot.

On Windows 8+, just press the "Start" button and type "Azure PowerShell", wait for the program to appear in the search, and press enter.

Before you can proceed to use any commands (or cmdlets as they like to call them over there), you need to sign-in.

```powershell
PS C:\> Add-AzureAccount
```

A window will pop-up prompting for your username and password. Once logged in, a default subscription will be selected.

```powershell
VERBOSE: Account "example@contoso.com" has been added.
VERBOSE: Subscription "Free Trial" is selected as the default subscription.
VERBOSE: To view all the subscriptions, please use Get-AzureSubscription.
VERBOSE: To switch to a different subscription, please use Select-AzureSubscription.
```

In order to avoid the pop-up every now and then, you can execute the following after executing the above.

```powershell
PS C:\> $cred = Get-Credential
PS C:\> Add-AzureAccount -Credential $cred
```

Your subscriptions are the equivalent of those found in https://account.windowsazure.com/Subscriptions. If you require to change your subscription, first get the list of all of your subscriptions.

```powershell
PS C:\> Get-AzureSubscription
```

You will get all *Subscriptions Names* and IDs. To proceed with the change of the subscription, use the following command.

```powershell
PS C:\> $mySubscription = "My Subscription Name"
PS C:\> Select-AzureSubscription $mySubscription
```

### Storage

Before you proceed any further, you need to set the storage that will be used for any subsequent commands (including creating your VM). If you get your current subscription, notice that *CurrantStorageAccountName* is empty.

```powershell
PS C:\> Get-AzureSubscription
SubscriptionName                         : Free Trial
SubscriptionId                           : 1a11aa1a-a11a-111a-1a1a-1a1111aaa11a
ServiceEndpoint                          : https://management.core.windows.net/
ResourceManagerEndpoint                  : https://management.azure.com/
GalleryEndpoint                          : https://gallery.azure.com/
ActiveDirectoryEndpoint                  : https://login.windows.net/
ActiveDirectoryTenantId                  : 111aa11a-1a11-11a1-a111-1aaaaa1aaa11
ActiveDirectoryServiceEndpointResourceId : https://management.core.windows.net/
SqlDatabaseDnsSuffix                     : .database.windows.net
IsDefault                                : True
Certificate                              :
RegisteredResourceProvidersList          : {}
CurrentStorageAccountName                :
ActiveDirectoryUserId                    : example@contoso.cm
TokenProvider                            : Microsoft.WindowsAzure.Commands.Utilities.Common.Authentication.AdalTokenProvider
```

If you have an existing storage account, run the following.

```powershell
PS C:\> Get-AzureStorageAccount
PS C:\> $myStorageName = "yourstoragenamewithoutspaces"
```

If not, just create one.

```powershell
PS C:\> $myStorageName = "yourstoragenamewithoutspaces"
PS C:\> $myLocation = "West Europe"
PS C:\> New-AzureStorageAcount -StorageAccountName $myStorageName -Location $myLocation
```

If you get an error saying that the name is already taken, just change the $myStorageName and re-run the command. To get a list of locations, run the following command.

```powershell
PS C:\> Get-AzureLocation
```

Now set the newly created storage as your default in your subscription.

```powershell
PS C:\> $mySubscription = "My Subscription Name"
PS C:\> Set-AzureSubscription -SubscriptionName $mySubscription -CurrentStorageAccount $myStorageName
```

### Certificates

This wasted me nearly 3 hours until we got it figured out right. Follow the instructions at http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-use-ssh-key/. You have instructions for both Linux and Windows.

I created mine with my CentOS 6.5 Linux machine at my home which we use for testing. Reason being is that openssl comes included and therefore we did not require to install any additional software.

I followed the instructions, however you must *note* with a big bold that the keys generated are in *x509* format. Both PuTTY and the ssh command on linux machines use *rsa* format. What you need to do is the following (assuming you used the filenames in the tutorial).

```
-bash-4.1# openssl rsa -in myPrivateKey.key -out myPrivateKey.rsa
```

You can then use the rsa key to login via shell or use the PuTTYgen tool to generate a ".ppk" file to be used with PuTTY.

```
-bash-4.1# ssh -i myPrivateKey.rsa -p <port number> user@something.cloudapp.net
```

Also, you will need the Fingerprint of the certificate. On Linux, you can easily get this by running the following command.

```
-bash-4.1# openssl x509 -in myCert.pem -fingerprint -noout | sed -e 's/^.*\=//g' -e 's/://g'
1A11111A1111AAA1A1111AA11AA111111A11A1A1
```

The "1A11111A1111AAA1A1111AA11AA111111A11A1A1" is the Fingerprint. For the Windows equivalent, we guess you need to Google a bit :¬).

You can download both PuTTYgen and PuTTY here http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html.

### Cloud Service

Alright sparky, we are zeroing in. With certificates under our belt (myCert.cer), we can proceed with the last few steps.

```powershell
PS C:\> $myService = "yourservicename"
PS C:\> $myLocation = "West Europe"
PS C:\> New-AzureService -ServiceName $myService -Location $myLocation
PS C:\> Add-AzureCertificate -CertToDeploy "C:\...\...\...\myCert.cer" -ServiceName $myService
```

Now the following is really important. First, think of the Linux admin username that you will use (no spaces or fancy characters). We am using "dbusuttil" in my case. Note how the "Path" is set with the username in place. *Very important*. You will also need the Fingerprint we retrieved earlier.

```powershell
PS C:\> $SSHKey = New-AzureSSHKey -PublicKey -Fingerprint 1A11111A1111AAA1A1111AA11AA111111A11A1A1 -Path "/home/dbusuttil/.ssh/authorized_keys"
```

### (The Sacred) CentOS 6.5 Linux VM

Finaaalllyyyy....... Can we start singing? First, get a Reserved Public IP Address.

```powershell
PS C:\> New-AzureReservedIP
```

Now let's create the machine.

```powershell
PS C:\> $name = "machinenamewithoutspaces"
PS C:\> $instanceSize = "Basic_A0"
PS C:\> $user = "dbusuttil"
PS C:\> $password = "mefancypassword"
PS C:\> New-AzureVMConfig -Name $name -InstanceSize $instanceSize -ImageName (Get-AzureVMImage | ? label -like "*CentOS 6.5 x64 v13.5.3*")[0].ImageName ` | Add-AzureProvisioningConfig -Linux -LinuxUser $user -Password $password -SSHPublicKeys $SSHKey | New-AzureVM -ServiceName $myService -ReservedIPName (Get-AzureReservedIP).label
```

Don't forget to change the user please. And as for InstanceSize, the following are available (to-date):

1. Basic\_A0, Basic\_A1, Basic\_A2, Basic\_A3, Basic\_A4 (Basic General Purpose Instances).
2. ExtraSmall, Small, Medium, Large, ExtraLarge (Standard General Purpose Instances).
3. A5, A6, A7 (Memory Intensive Instances).
4. A8, A9 (Compute Intensive Instances).

## Pricing

Last but not least, your pricing considerations should include:

1. Compute - Virtual Machine (http://azure.microsoft.com/en-us/pricing/details/virtual-machines/).
2. Data Services - Storage (http://azure.microsoft.com/en-us/pricing/details/storage/).
3. Networking Services - Data Transfers (http://azure.microsoft.com/en-us/pricing/details/data-transfers/).

Enjoy, really.