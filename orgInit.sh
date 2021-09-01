
# Create the scratch org (uncomment for local development)
# sfdx force:org:delete -u electron-motors-sfdx
# sfdx force:org:create -f config/project-scratch-def.json --setalias electron-motors-sfdx --setdefaultusername

# Create the scratch org (uncomment for the SFDX Deployer)
sfdx shane:org:create -f config/project-scratch-def.json -d 3 -s -n --userprefix admin --userdomain electron.demo

# Install the Salesforce Mobile connected apps - https://appexchange.salesforce.com/listingDetail?listingId=a0N3000000B4cUuEAJ
# (It's not possible to create custom mobile notifications or create mobile security policies without this being installed)
sfdx force:package:install -p 04t3A000001AJf2QAG --wait 20

# Push the metadata into the new scratch org.
sfdx force:source:push

# Apply the custom attributes to the connected app for "Salesforce for iOS"
sfdx shane:connectedapp:attributes -n "Salesforce for iOS" -a mobileAttributes.json

# Assign the permset to the default admin user.
sfdx force:user:permset:assign -n electron

# Assign a special analytics (non-Modify-All) permset to the Integration User used by Einstein Analytics
sfdx shane:user:permset:assign -n analytics -g Integration -l User

# Import the data required by the demo
# (Exported using 'sfdx automig:dump --objects Account,Contact,Vehicle__c,Loan__c --outputdir ./data')
sfdx automig:load --inputdir ./data --deletebeforeload

# Deploy the metadata for the the dataflow (this needed to happen AFTER the other meta data was pushed and the permset was applied to the Integration user)
sfdx force:source:deploy -p dataflow

# Start the dataflow for the Analytics.
sfdx shane:analytics:dataflow:start -n Electron

# Deploy the metadata for the visualizations
sfdx force:source:deploy -p visualizations

# Activate the custom theme.
sfdx shane:theme:activate -n Electron

# Set the default password.
sfdx shane:user:password:set -g User -l User -p sfdx1234

# Open the demo org.
sfdx force:org:open
