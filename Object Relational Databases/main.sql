create type type_birthdate as(
	day varchar(15),
	month varchar(15),
	year varchar(4)
);

create type type_birthtime as (
	hour varchar(20),
	minutes varchar(20),
	seconds varchar(20)
);

create type type_users as (
	id int,
	name varchar(60),
	email varchar(60),
	password varchar(60),
	birthdate type_birthdate,
	birthtime type_birthtime, 
	created_at timestamp,
	update_at timestamp
);

create sequence seq_users_id;

create table users of type_users (
	id primary key default nextval('seq_users_id'),
	created_at default now(),
	update_at default now()
)

create table payment_informations (
	id serial primary key, 
	id_user int, 
	id_user_vip int,
	payment_basic_informations json, 
	created_at timestamp default now(),
	update_at timestamp default now(), 
	
	CONSTRAINT fk_users
      FOREIGN KEY(id_user) 
	  REFERENCES users(id) on delete cascade,
	
	CONSTRAINT fk_payment_vip 
		FOREIGN KEY (id_user_vip) 
		REFERENCES users_vip (id_vip) on delete cascade
)

alter table payment_informations
	add column id_user_vip int;

alter table payment_informations alter column id_user drop not null;

ALTER TABLE payment_informations
    ADD CONSTRAINT fk_payment_vip FOREIGN KEY (id_user_vip) REFERENCES users_vip (id_vip);

create table users_vip (
	id_vip serial primary key, 
	payment_method_quantity int default 5, 
	billet_payment_type boolean default true, 
	billet_limit_per_month decimal not null
) INHERITS (users);

create table address (
	id serial primary key, 
	id_user int, 
	id_user_vip int,
	line_one json,
	line_two varchar(255)array[2],
	zipcode varchar(30),
	country varchar(60), 
	created_at timestamp default now(),
	update_at timestamp default now(), 
	
	CONSTRAINT fk_users_address
      FOREIGN KEY(id_user) 
	  REFERENCES users(id)
	  on delete CASCADE
	  ,
	  
	 CONSTRAINT fk_users_address_vip
      FOREIGN KEY(id_user_vip) 
	  REFERENCES users_vip(id_vip)
	  on delete CASCADE
)


insert into users(name, email, password, birthdate, birthtime) values  
('Vitor Rafael', 'vitor.rafael1518@gmail.com', '123456', row('18', '05', '2023'), row('05', '30', '55')) returning id;

insert into address(id_user, line_one, line_two, zipcode, country) 
values (
	7, 
	'{
	  "street": "Candido martins", 
	  "neighbourhood": "Bairro I", 
	  "number": 26
	}', 
	array['House with grey door', 'Glass windows'], 
	'59670000', 
	'Brazil'
)

insert into payment_informations(id_user, payment_basic_informations) 
values (
	4, 
	'{
	  "card_number": "4444555566661111", 
	  "security_code": "896", 
	  "expired_date": "12/28", 
	  "card_holder_name": "VITOR D R SILVA", 
	  "tax_id": "12345678996"
	}'
)

insert into users_vip(name, email, password, birthdate, birthtime, payment_method_quantity, billet_payment_type, billet_limit_per_month) values  
('Angelica', 'angelica@gmail.com', '123456', row('18', '05', '2023'), row('05', '30', '55'), 5, true, 10000) returning id_vip;

select * from users_vip;
select * from only users;

insert into address(id_user_vip, line_one, line_two, zipcode, country) 
values (
	4, 
	'{
	  "street": "Candido martins Vip", 
	  "neighbourhood": "Bairro I Vip", 
	  "number": 26
	}', 
	array['House with grey door', 'Glass windows'], 
	'59670000', 
	'Brazil'
)

insert into payment_informations(id_user_vip, payment_basic_informations) 
values (
	4, 
	'{
	  "card_number": "4444555566669999", 
	  "security_code": "896", 
	  "expired_date": "12/28", 
	  "card_holder_name": "VITOR M S R", 
	  "tax_id": "12345679632"
	}'
)

select * from users_vip uv 
where uv.email = 'vitor.rafaeldeveloper2@gmail.com';

select * from users_vip uv 
left join address a on a.id_user_vip = uv.id_vip 
inner join payment_informations pi2 on pi2.id_user_vip = uv.id_vip
where uv.email = 'vitor.rafaeldeveloper2@gmail.com';

update users_vip
	set email = 'vitor.rafaeldeveloper3@gmail.com'
where email = 'vitor.rafaeldeveloper2@gmail.com';

update users_vip
	set birthdate = row('19', '06', '2020')
where email = 'vitor.rafaeldeveloper3@gmail.com';

update address 
	set line_two  = array['xxxxxxxxxxxxxx', 'yyyyyyyyyyyyyyyyyyyy']
where address.id in (
	select a.id from users_vip uv 
	left join address a on a.id_user_vip = uv.id_vip 
	where uv.email = 'angelica@gmail.com' limit 1
)

delete from users_vip 
where users_vip.email = 'vitor.rafaeldeveloper3@gmail.com';

select 
	uv."name", 
	uv.email, 
	pi2.payment_basic_informations::json->>'card_number' as card_number, 
	pi2.payment_basic_informations::json->>'security_code' as security_code, 
	uv.birthdate as birthday, 
	array_to_string(a.line_two[1:1], ',') as complements1, 
	array_to_string(a.line_two[2:2], ',') as complements2
	from users_vip uv 
	left join address a on a.id_user_vip = uv.id_vip 
	inner join payment_informations pi2 on pi2.id_user_vip = uv.id_vip
	where uv.email = 'angelica@gmail.com';

create VIEW users_vip_view_3 AS (
	select 
	uv."name", 
	uv.email, 
	pi2.payment_basic_informations::json->>'card_number' as card_number, 
	pi2.payment_basic_informations::json->>'security_code' as security_code, 
	uv.birthdate as birthday, 
	array_to_string(a.line_two[1:1], ',') as complements1, 
	array_to_string(a.line_two[2:2], ',') as complements2
	from users_vip uv 
	left join address a on a.id_user_vip = uv.id_vip 
	inner join payment_informations pi2 on pi2.id_user_vip = uv.id_vip
	where uv.email = 'angelica@gmail.com'
);