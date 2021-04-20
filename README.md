# Blockchain-Medical-Records-Project
This is a project to explore how medical record keeping could work on the Ethereum Blockchain.

# Description and functionalities
Users can keep track of their medical records on chain, not depending on a single entity and making their data accessable to the parties they allow. Ideally, access to medical data should be convenient while keeping things as private as possible for the users. For now only a back end contract prototype was developed and a front end is to be done.

'MR.sol' is the prototype back end contract.
An overview of the data structure is that Persons (each with their address) can be created and Medical Records can be added to each Person. To add or edit the basic personal data of an address, its owner should use the 'createEditPerson' function. The main identification variable for each person (next to its address) is the hash of the person's full Name, birth country and national ID concatenated. This hash should be generated on the client side application (not coded yet), so that the data that makes a person easily identificable doesn't enter the blockchain, making each person pseudonymus on chain. If needed, each person can proof to a third party that they are the real owners of the address by generating the hash based on their data (off chain).

In order to keep track of eventual changes to the basic data of each Person, each time the'createEditPerson' function is called it generates a 'checkValueCurrent' based on:
- hashed_fullName_birthCountry_nationalID
- birthYear, birthMonth & birthDay
- gender
This 'checkValueCurrent' is the stored in the array 'checkValueHistory'.

An implicit privacy feature is that is that you can't get the data of a person unless you know his or her address as persons are accessed from a mapping ('persons'). On top of that, if you know a person's address you still need his or her permission to be able to view or edit their data. These view/edit permissions can be managed with the 'viewerAddRemove' and 'editorAddRemove' functions.

# Limitations and potential improvement points
A potential privacy leak point is the variable 'extReferences'. The purpose of this variable is to store links to other resources such as images or PDFs on other sites. Users should be wary of what they reference here to protect their privacy, making sure their data is anonymized.

Date handling. Both the Medical Recort dates and birth dates of each user are based on Ethereum/Solidity's 'block.timestamp' which works starting 1970. This is fine to timestamp new Medical Records but is an issue to store birth dates. Currently 'BokkyPooBahsDateTimeLibrary.sol' is being used to check the validity of the birth dates entered by users, however in the future this functionality could be taken over by the front end program, avoiding the >= 1970 limitation.

'createEditPerson' function. As it can overwrite previously stored data, it would be good to alert the user about that and ask for confirmation. This should be done in conjunction with the front end though.


