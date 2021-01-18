CREATE TABLE entity (
    id                       INTEGER,
    name                     TEXT    NOT NULL,
    jurisdiction             TEXT,
    jurisdiction_description TEXT,
    company_type             TEXT,
    id_address               INTEGER,
    incorporation_date       DATE,
    inactivation_date        DATE,
    status                   TEXT,
    service_provider         TEXT,
    country_codes            TEXT,
    countries                TEXT,
    source                   TEXT,
    PRIMARY KEY (
        id
    ),
    FOREIGN KEY (
        id_address
    )
    REFERENCES address (id) 
);

;
