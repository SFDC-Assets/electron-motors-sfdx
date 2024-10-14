# Create the scratch org (uncomment for the SFDX Deployer)
sf demoutil org create scratch -f config/project-scratch-def.json -d 5 -s -p admin -e electron.demo

# Install the Salesforce Mobile connected apps - https://appexchange.salesforce.com/listingDetail?listingId=a0N3000000B4cUuEAJ
# (It's not possible to create custom mobile notifications or create mobile security policies without this being installed)
sf package install -p 04t3A000001AJf2QAG --wait 20

# Push the metadata into the new scratch org.
sf project deploy start

# Apply the custom attributes to the connected app for "Salesforce for iOS"
sfdx shane:connectedapp:attributes -n "Salesforce for iOS" -a mobileAttributes.json

# Assign the permset to the default admin user.
sf org assign permset -n electron

# Assign a special analytics (non-Modify-All) permset to the Integration User used by Einstein Analytics
sf org assign permset -n analytics -b integ

# Import the data required by the demo
# (Exported using 'sfdx automig:dump --objects Account,Contact,Vehicle__c,Loan__c --outputdir ./data')
sf automig load --inputdir ./data --deletebeforeload

# Deploy the metadata for the the dataflow (this needed to happen AFTER the other meta data was pushed and the permset was applied to the Integration user)
sf project deploy start -d dataflow

# Start the dataflow for the Analytics.
sfdx shane:analytics:dataflow:start -n Electron

# Deploy the metadata for the visualizations
sf project deploy start -d visualizations

# Activate the custom theme.
sfdx shane:theme:activate -n Electron

# Set the default password.
sf demoutil user password set -p salesforce1 -g User -l User

# Open the demo org.
sf org open
