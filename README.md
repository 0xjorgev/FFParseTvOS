# FFParseTvOS
A Minimalistic Swift Class that allows to use the Parse.com REST API from a single Class on the new TvOS without any other framework

#Example

        //Parse Calls
        let parse:FFParseRequest = FFParseRequest()
        //In this array add the name of the fiels in your parse.com object not the name of the object
        let includeArr = ["obj","media","userId"]
        parse.delegate = self
        
        /*
        
            Try one of this at the time.
        
        */
        
        //Retrive a Collection of Parse.com plane objects
        parse.retriveParseObjectByClassName("Post", include: nil)
        
        //Retrive a Collection Parse.com with it's relational fields
        parse.retriveParseObjectByClassName("Post", include: includeArr)
        
        //Retrieve an Object by Object Id and Class Name
        parse.retriveParseObjectById("Post", objectId: "p0rKbcZOjX", include:nil)
        
        //Retrieve an Object by Object Id and Class Name with relational data
        parse.retriveParseObjectById("Post", objectId: "p0rKbcZOjX", include:nil)
        
        //Update a parse Object
        parse.updateObject("Post", objectId: "p0rKbcZOjX", values: ["content":"This is the new updated content!!", "text":"This is the updated Text!!","number":237])
