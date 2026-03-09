const mongoose = require ('mongoose');
const bcrypt =require('bcrypt');
const userschema = new mongoose.Schema ({
    name:{
        required:[true,"Name is required"],
        type:String,
        
    },
    password:{
        required:[true,"password is required"],
        type:String,
        minLength:[6,"'password must be at least 6 characters"],
        select:false,
        

    },
    email:{
        type:String,
        required:[true,"email is required"],
        unique:true,
        trim:true,
        lowercase:true,
        match:[/^\S+@\S+\.\S+$/, "Please enter a valid email"],
    },
    weight:{
        type:Number,
        required:[true,"weight is required"],
    },
    height:{
        type:Number,
        required:[true,"height is required"],
    },
    dateOfBirth:{
        type:Date,
        required:[true,"date of birth is required"],
    },
    goal:{
        type:String,
        required:[true,"goal is required"],
        enum:["lose weight","gain muscle","maintain fitness"],

    }
    userschema.pre('save',async function(next){
        if(!this.isModified('password')){
            return next();
        }   
        try{
            const salt = await bcrypt.genSalt(10);
            this.password = await bcrypt.hash(this.password,salt);
            next();
        }        catch(err){
            next(err);
        }
    });


});
module.exports=mongoose.model('User',userschema);