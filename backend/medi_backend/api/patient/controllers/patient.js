'use strict';

/**
 * Read the documentation (https://strapi.io/documentation/v3.x/concepts/controllers.html#core-controllers)
 * to customize this controller
 */

const { parseMultipartData, sanitizeEntity } = require('strapi-utils');

module.exports = {
    async create(ctx) {
        let entity;
        const { data, files } = parseMultipartData(ctx);
        var passwordEncrypted= await strapi.plugins['users-permissions'].services.user.hashPassword({
            password: data.password,
        })
        var user = await strapi.query('user', 'users-permissions').findOne({
            email: data.email
        })
        if(user){
            return ctx.badRequest("El correo ya existe")
        }          
        var rolePatient = await strapi.query('role', 'users-permissions').findOne({
            name: "Patient"
        });
        var user = await strapi.query('user', 'users-permissions').create({
            username: data.email,
            email: data.email,
            password: passwordEncrypted,
            confirmed: false,
            blocked: false,
            provider: "local",
            role: rolePatient.id,
            created_by: 1,
            updated_by: 1
        })
        data.user = user.id
        if(data.gender==0||data.gender==1){
            var genders = await strapi.services.gender.find({});
            data.gender = genders[data.gender].id
        }else{
            return ctx.badRequest("El género no es válido")
        }
        entity = await strapi.services.patient.create(data, { files });
        return sanitizeEntity(entity, { model: strapi.models.patient });
    },
    async update(ctx) {
        const { id } = ctx.params;
        let entity;
        const { data, files } = parseMultipartData(ctx);
        const patient = await strapi.services.patient.findOne({id}, ['photo']);
        if(data.gender==0||data.gender==1){
            var genders = await strapi.services.gender.find({});
            data.gender = genders[data.gender].id
        }
        entity = await strapi.services.patient.update({ id }, data, { files });
        if(Object.entries(files).length != 0){
            if(patient.photo){
                await strapi.plugins.upload.services.upload.remove(patient.photo);
            }
        }
        return sanitizeEntity(entity, { model: strapi.models.patient });
    },
    async chatbotAnswer(ctx) {
        let response = await global.nlp.process('es', ctx.request.body.question);
        return response.answer;
    }
};
