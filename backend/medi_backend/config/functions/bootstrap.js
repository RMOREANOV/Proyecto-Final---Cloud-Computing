'use strict';

/**
 * An asynchronous bootstrap function that runs before
 * your application gets started.
 *
 * This gives you an opportunity to set up your data model,
 * run jobs, or perform some special logic.
 *
 * See more details here: https://strapi.io/documentation/v3.x/concepts/configurations.html#bootstrap
 */

const { dockStart } = require('@nlpjs/basic');
const fs = require('fs');

module.exports = async () => {
    var adminCount = await strapi.query('user', 'admin').count();
    var userAdmin = {
        firstname: "Rolando Vidal",
        lastname: "Moreano Vargas",
        email: "admin@mediteam.com",
        password: await strapi.plugins['users-permissions'].services.user.hashPassword({
            password: "Admin1234",
        }),
        isActive: true
    }
    if(adminCount==0){
        await strapi.query('user', 'admin').create(userAdmin);
    }
    var roleCount = await strapi.query('role', 'users-permissions').count();
    if(roleCount==2){
        const lang = 'en';
        const plugins = await strapi.plugins['users-permissions'].services.userspermissions.getPlugins(lang);
        const permissions = await strapi.plugins['users-permissions'].services.userspermissions.getActions(plugins);
        await strapi.plugins['users-permissions'].services.userspermissions.createRole({
            name: "Administrator",
            description: "Default role given to administrator user.",
            permissions,
            users: []
        });
        await strapi.plugins['users-permissions'].services.userspermissions.createRole({
            name: "Doctor",
            description: "Default role given to doctor user.",
            type: "doctor"
        });
        await strapi.plugins['users-permissions'].services.userspermissions.createRole({
            name: "Patient",
            description: "Default role given to patient user.",
            type: "patient"
        });
    }
    var roleAdministrator = await strapi.query('role', 'users-permissions').findOne({
        name: "Administrator"
    });
    if(strapi.services.administrator){
        var administratorCount = await strapi.services.administrator.count();
        if(administratorCount==0){
            var userAdministrator = await strapi.query('user', 'users-permissions').create({
                username: userAdmin.email,
                email: userAdmin.email,
                password: userAdmin.password,
                confirmed: false,
                blocked: false,
                provider: "local",
                role: roleAdministrator.id,
                created_by: 1,
                updated_by: 1
            })
            await strapi.services.administrator.create({
                firstname: userAdmin.firstname,
                lastname: userAdmin.lastname,
                phone: "987-6543",
                user: userAdministrator.id
            })
        }
    }
    if(strapi.services.gender){
        var genderCount = await strapi.services.gender.count();
        if(genderCount==0){
            await strapi.services.gender.create({
                name: "Male"
            })
            await strapi.services.gender.create({
                name: "Female"
            })
        }
    }
    if(strapi.services.specialty){
        var specialtyCount = await strapi.services.specialty.count();
        if(specialtyCount==0){
            await strapi.services.specialty.create({
                name: "Medicina General"
            })
        }
    }
    if(strapi.services.doctor){
        var doctorCount = await strapi.services.doctor.count();
        var specialty1 = await strapi.services.specialty.findOne({})
        var genderMale = await strapi.services.gender.findOne({name: "Male"})
        var genderFemale = await strapi.services.gender.findOne({name: "Female"})
        if(doctorCount==0){
            var roleDoctor = await strapi.query('role', 'users-permissions').findOne({
                name: "Doctor"
            });
            var doctor1Data = {
                firstname: "Manuel",
                lastname: "Pérez Martínez",
                description: "Más de 13 años de experiencia cuidando la sonrisa de mis pacientes.",
                phone: "944333222",
                password: await strapi.plugins['users-permissions'].services.user.hashPassword({
                    password: "Doctor1",
                })
            }
            var userDoctor1 = await strapi.query('user', 'users-permissions').create({
                username: "doctor1@gmail.com",
                email: "doctor1@gmail.com",
                password: doctor1Data.password,
                confirmed: false,
                blocked: false,
                provider: "local",
                role: roleDoctor.id,
                created_by: 1,
                updated_by: 1
            })
            await strapi.services.doctor.create({
                firstname: doctor1Data.firstname,
                lastname: doctor1Data.lastname,
                description: doctor1Data.description,
                phone: doctor1Data.phone,
                user: userDoctor1.id,
                gender: genderMale.id,
                specialty: specialty1.id
            })
            var doctor2Data = {
                firstname: "Sara",
                lastname: "Moreno Villafuerte",
                description: "Más de 10 años de experiencia cuidando de las futuras madres.",
                phone: "944123246",
                password: await strapi.plugins['users-permissions'].services.user.hashPassword({
                    password: "Doctor2",
                })
            }
            var userDoctor2 = await strapi.query('user', 'users-permissions').create({
                username: "doctor2@gmail.com",
                email: "doctor2@gmail.com",
                password: doctor2Data.password,
                confirmed: false,
                blocked: false,
                provider: "local",
                role: roleDoctor.id,
                created_by: 1,
                updated_by: 1
            })
            await strapi.services.doctor.create({
                firstname: doctor2Data.firstname,
                lastname: doctor2Data.lastname,
                description: doctor2Data.description,
                phone: doctor2Data.phone,
                user: userDoctor2.id,
                gender: genderFemale.id,
                specialty: specialty1.id
            })
        }
    }

    const dock = await dockStart({ use: ['Basic']});
    const nlp = dock.get('nlp');
    const data = fs.readFileSync('./assets/model/model.nlp', 'utf8');
    nlp.import(data);
    global.nlp = nlp;

    disableMedicalConsultation()
    setInterval(async () => {
        await disableMedicalConsultation()
    }, 60000);
};

async function disableMedicalConsultation() {
    var today = new Date();
    var medicalConsultation = await strapi.services['medical-consultation'].find({isVisible: true}, {});
    for(var i=0;i<medicalConsultation.length;i++){
        var entity = medicalConsultation[i]
        if(today.getTime()>new Date(entity.datetime).getTime()+30*60000){
            const { id } = entity;
            await strapi.services['medical-consultation'].update({ id }, { isVisible: false });
        }
    }
}