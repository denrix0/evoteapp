# Electronic Voting System


## Tech Stacks?
- Android App
  - Flutter
- Server
  - Flask
  - Brownie
  - MongoDB
  - MySQL
- WebUI
  - ReactJS


## Specifications
1. Authorization : JWT(HS512) with expiry based on config
2. PIN : 8+ Digits
3. Key Pair : RSA (Key Size: 2048 bits)
4. Shared Key: AES (Key Size: 256 bits)
5. Auth Tokens : Random 256-bit Hex Strings
6. Master Token : Hex value of the SHA256 Hash of the concatenated tokens seperated by '.'
   > `Token order: <uid>.<totp1>.<totp2>`

   Example:
   > 
   > Token String: \
   > `913504352739548c95037c6719e27069232e57a592756d646d3b7722fe214a25.99efd144b4dc3609134da15098a2661b310485402ee985a4ae6860023285bfc7.d853d9d41cb8c1d6c07b786c5fc5725a452ff7d9a437f81457b01b92b17a62f7`
   > 
   > Master Token: \
   > `1F3259D5FD2C139FEE9E188B810850C2B7B5E537CED083A3585855EF22837683`
## Authentication API
1. Client Interface
   1. Login (/login)
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         {
            "id": int,
            "pin": string
         }
         ```
      2. Response Example
         ```
         {
            "jwt": string,
            "pub_key": string
         }
         ```
   2. Standard Auth (/auth_verify)
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Bearer <jwt>
         {
            "auth_type": string,
            "auth_content": string,
            "enc_key": string,
            "iv": string
         }
         ``` 
      2. Response Example
         ```
         {
            "method: string,
            "token": string
         }
         ```
   3. Submit Form Auth (/submit)
      1. Request Example
         ```
         POST /cgi-bin/process.cgi HTTP/1.1
         Authorization: Bearer <jwt>
         {
            "master_token": string,
            "form_option": string,
            "enc_key": string,
            "iv": string
         }
         ```
      2. Response Example
         ```
         {
            "vote_status": string,
            "message": string
         }
         ```
2. WebUI API
   1. Vote Config
      1. Request Example
            ```
            POST /cgi-bin/process.cgi HTTP/1.1
            {
               "type": string,
               "data": { ... }
            }
            ```
            > Possible types : 'fetch', 'edit', 'reset' \
            > 'data' field is only needed on 'edit' type
            > ```
            > "data": {
            >      "property": string,
            >      "value": string 
            > }
            >```

      2. Response Example
         ```
         {
            "message": string,
            "data": { ... }
         }
         ```
         > Message about what happened or something
         > data field only if request type is 'fetch'
   2. Vote User
      1. Request Example
            ```
            POST /cgi-bin/process.cgi HTTP/1.1
            Authorization: Bearer <jwt>
            {
               "type": string,
               "data": { ... }
            }
            ```
            > Possible types : 'add', 'delete' \
            > 'data' format per type: \
            > \
            > add:
            > ```
            > "data": {
            >     "id": int,
            >     "pin": string,
            >     "totp1": string,
            >     "totp2": string,
            > }
            > ```
            > delete:
            > ```
            > "data": {
            >     "id": int 
            > }
            > ```
      2. Response Example
         ```
         {
            "message": string
         }
         ```
         > Message about what happened or something
         
Fail Example
```
{
   "error_type": string,
   "message": string
}
```
## Data Storage
### MySQL
> Stored only on owner machine \
> Preferably only local network access

> Permissions: \
> evote_node (user_details: ALL, voting_config: select) \
> evote_owner (ALL)

Database - evoteapp
1. 'user_details' Table
   | ID(int) | Pin(text) | Salt(string32)  | TOTP 1(text) | TOTP 2(text) |
   | ------- | --------- | --------------- | ------------ | ------------ |
   | 2342333 | 324233355 | adascdasdascdas | 2v312v3123v1 | g3aa4f353454 |

2. 'voting_config' Table
   | name(string64)  | value(text)          |
   | --------------- | -------------------- |
   | prompt          | prompt content       |
   | options         | pickled options      |
   | req_methods     | pickled method list  |
   | expiry          | expiry in seconds    |
   | ongoing         | boolean value        |

   > Method Names: "uid", "totp1", "totp2" \
   > Expiry Default: 600 seconds \
   > Ongoing Default: False

### MongoDB
User data
   ```
   {
      'user_id': <User ID>
      'jwt': <JWT>
      'auth_tokens': {
         <Method Name> : <Token>,
         ...
      },
      'msg_key': <Key RSA-PVT/AES>
   }
   ```
## Todo
- [ ] Fix UID Auth
- [ ] Authorize Nodes on the Blockchain
- [ ] Make Auth Methods Selectable
- [ ] Better way of buffering voters
- [ ] Implement Login Attempt Limiting
- [x] Add set defaults button